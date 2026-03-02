import prologue
import prologue/middlewares/staticfile
import std/xmltree
import std/[tables, strutils, options, json]
import db_connector/db_sqlite

import ../config
import ../content/indexer
import ../content/types
import ./templates
import ../utils/jwt_helpers as jwtUtils
import ../utils/db_helpers
from ../utils/seqs import head

# ── helpers ───────────────────────────────────────────────────────────────────

proc requireAuth(ctx: Context): Option[string] =
  let cookieHeaders = ctx.request.getHeader("Cookie")
  for header in cookieHeaders:
    for part in header.split(';'):
      let kv = part.strip().split('=', 1)
      if kv.len == 2 and kv[0].strip() == "token":
        let tokenStr = kv[1].strip()
        if jwtUtils.verify(tokenStr):
          return some(jwtUtils.decode(tokenStr))
  return none(string)

proc sendRedirect(ctx: Context, url: string) =
  ctx.response.setHeader("Location", url)
  resp("", Http303)

proc jsonResp(ctx: Context, node: JsonNode, code = Http200) =
  ctx.response.setHeader("Content-Type", "application/json")
  resp($node, code)


proc home(ctx: Context, store: ContentStore, cfg: SiteConfig) {.async.} =
  let latest_blogs = listCollection(store, "blog").head(5)
  let latest_projects = listCollection(store, "projects").head(5)

  var body = ""

  body.add renderHTMLTemplate("src/web/templates/components/homepage.html", {"title": xmltree.escape(cfg.siteTitle)}.toTable)

  body.add "<h2>Latest posts</h2><ul>"
  for d in latest_blogs:
    body.add docListItem("/blog", d)
  body.add "</ul>"

  body.add "<h2>Latest projects</h2><ul>"
  for d in latest_projects:
    body.add docListItem("/projects", d)
  body.add "</ul>"

  resp htmlLayout(cfg.siteTitle, body)


proc blog(ctx: Context, store: ContentStore, cfg: SiteConfig) {.async.} =
  let posts = listCollection(store, "blog")
  var body = "<h1>Blog</h1><ul>"
  for d in posts:
    body.add docListItem("/blog", d)
  body.add "</ul>"
  resp htmlLayout("Blog - " & cfg.siteTitle, body)


proc blog_slug(ctx: Context, store: ContentStore, cfg: SiteConfig) {.async.} =
  let slug = ctx.getPathParams("slug")
  let found = findDoc(store, "blog", slug)
  if found.isSome:
    let d = found.get
    resp htmlLayout(d.meta.title, docPage(d))
  else:
    ctx.response.code = Http404
    resp htmlLayout("Not found", "<h1>404</h1><p>Post not found.</p>")


proc projects(ctx: Context, store: ContentStore, cfg: SiteConfig) {.async.} =
  let docs = listCollection(store, "projects")
  var body = "<h1>Projects</h1>"
  if docs.len == 0:
    body.add "<p>No project docs yet. Add markdown files under <code>content/projects</code>.</p>"
  else:
    body.add "<ul>"
    for d in docs:
      body.add docListItem("/projects", d)
    body.add "</ul>"
  resp htmlLayout("Projects - " & cfg.siteTitle, body)


proc projects_slug(ctx: Context, store: ContentStore, cfg: SiteConfig) {.async.} =
  let slug = ctx.getPathParams("slug")
  let found = findDoc(store, "projects", slug)
  if found.isSome:
    let d = found.get
    resp htmlLayout(d.meta.title, docPage(d))
  else:
    ctx.response.code = Http404
    resp htmlLayout("Not found", "<h1>404</h1><p>Project doc not found.</p>")


proc sec_vault_login(ctx: Context, cfg: SiteConfig) {.async.} =
  var notice = ""
  let err = ctx.getQueryParams("error")
  let ok  = ctx.getQueryParams("registered")
  if ok == "1":
    notice = "<p class='auth-notice auth-ok'>Account created — you can now log in.</p>"
  elif err == "wrong_password":
    notice = "<p class='auth-notice auth-err'>Wrong username or password.</p>"
  elif err == "username_taken":
    notice = "<p class='auth-notice auth-err'>Username already taken.</p>"
  elif err == "missing_fields":
    notice = "<p class='auth-notice auth-err'>Please fill in all fields.</p>"
  elif err == "password_mismatch":
    notice = "<p class='auth-notice auth-err'>Passwords do not match.</p>"
  var body = notice & renderHTMLTemplate("src/web/templates/components/sec-login.html")
  resp htmlLayout(cfg.siteTitle, body)

proc sec_vault(ctx: Context, cfg: SiteConfig) {.async.} =
  if requireAuth(ctx).isNone:
    sendRedirect(ctx, "/vault-login")
    return
  let body = renderHTMLTemplate("src/web/templates/components/sec-vault.html")
  resp htmlLayout(cfg.siteTitle, body)


proc loginHandler(ctx: Context, db: DbConn) {.async.} =
  let username = ctx.getPostParams("username")
  let password = ctx.getPostParams("password")

  if username.len == 0 or password.len == 0:
    sendRedirect(ctx, "/vault-login?error=missing_fields")
    return

  if not checkUserPassword(db, username, password):
    sendRedirect(ctx, "/vault-login?error=wrong_password")
    return

  let token = jwtUtils.sign(username)
  ctx.setCookie("token", token, path = "/", httpOnly = true, sameSite = Lax)
  sendRedirect(ctx, "/vault")


proc registerHandler(ctx: Context, db: DbConn) {.async.} =
  let username = ctx.getPostParams("username")
  let password = ctx.getPostParams("password")
  let confirm  = ctx.getPostParams("confirm_password")

  if username.len == 0 or password.len == 0 or confirm.len == 0:
    sendRedirect(ctx, "/vault-login?error=missing_fields")
    return
  if password != confirm:
    sendRedirect(ctx, "/vault-login?error=password_mismatch")
    return
  if registerUser(db, username, password):
    sendRedirect(ctx, "/vault-login?registered=1")
  else:
    sendRedirect(ctx, "/vault-login?error=username_taken")


# ── Vault API (JSON, requires auth) ──────────────────────────────────────────

proc apiVaultEntries(ctx: Context, db: DbConn) {.async.} =
  let maybeUser = requireAuth(ctx)
  if maybeUser.isNone:
    jsonResp(ctx, %*{"error": "Unauthorized"}, Http401)
    return
  let rows = getVaultEntries(db, maybeUser.get)
  var arr = newJArray()
  for row in rows:
    arr.add %*{"id": row[0], "site": row[1], "login": row[2], "ciphertext": row[3]}
  jsonResp(ctx, arr)


proc apiAddVaultEntry(ctx: Context, db: DbConn) {.async.} =
  let maybeUser = requireAuth(ctx)
  if maybeUser.isNone:
    jsonResp(ctx, %*{"error": "Unauthorized"}, Http401)
    return
  let site       = ctx.getPostParams("site")
  let login      = ctx.getPostParams("login")
  let ciphertext = ctx.getPostParams("ciphertext")
  if site.len == 0 or login.len == 0 or ciphertext.len == 0:
    jsonResp(ctx, %*{"error": "Missing fields"}, Http400)
    return
  if addVaultEntry(db, maybeUser.get, site, login, ciphertext):
    jsonResp(ctx, %*{"ok": true})
  else:
    jsonResp(ctx, %*{"error": "Failed"}, Http500)


proc apiDeleteVaultEntry(ctx: Context, db: DbConn) {.async.} =
  let maybeUser = requireAuth(ctx)
  if maybeUser.isNone:
    jsonResp(ctx, %*{"error": "Unauthorized"}, Http401)
    return
  let entryId = ctx.getPathParams("id")
  if deleteVaultEntry(db, maybeUser.get, entryId):
    jsonResp(ctx, %*{"ok": true})
  else:
    jsonResp(ctx, %*{"error": "Failed"}, Http500)


# ── Reviews ───────────────────────────────────────────────────────────────────

proc reviewsPage(ctx: Context, db: DbConn, cfg: SiteConfig) {.async.} =
  let maybeUser = requireAuth(ctx)
  let rows = getReviews(db)
  var reviewsHtml = ""
  for row in rows:
    reviewsHtml.add "<div class='review'>"
    reviewsHtml.add "<strong>" & xmltree.escape(row[0]) & "</strong>"
    reviewsHtml.add "<p>" & xmltree.escape(row[1]) & "</p>"
    reviewsHtml.add "<small>" & xmltree.escape(row[2]) & "</small>"
    reviewsHtml.add "</div>"
  if reviewsHtml.len == 0:
    reviewsHtml = "<p>No reviews yet. Be the first!</p>"

  let formHtml =
    if maybeUser.isSome:
      """<form action="/api/reviews" method="post" style="margin-bottom:2em;">
        <label for="review-text">Leave a review:</label>
        <textarea id="review-text" name="review_text" rows="4"
          style="width:100%;box-sizing:border-box;padding:0.5em;
                 border:1px solid var(--color-link);border-radius:4px;
                 background:var(--color-bg);color:var(--color-text);
                 font-family:var(--p-font);font-size:var(--p-font-size);"
          required placeholder="Write your review here&hellip;"></textarea>
        <button type="submit" style="margin-top:0.5em;">Submit Review</button>
      </form>"""
    else:
      "<p><a href=\"/vault-login\">Log in</a> to leave a review.</p>"

  let body = renderHTMLTemplate("src/web/templates/components/reviews.html",
    {"reviews": reviewsHtml, "form": formHtml}.toTable)
  resp htmlLayout("Reviews - " & cfg.siteTitle, body)


proc apiAddReview(ctx: Context, db: DbConn) {.async.} =
  let maybeUser = requireAuth(ctx)
  if maybeUser.isNone:
    sendRedirect(ctx, "/vault-login")
    return
  let text = ctx.getPostParams("review_text")
  if text.strip().len == 0:
    sendRedirect(ctx, "/reviews?error=empty")
    return
  discard addReview(db, maybeUser.get, text.strip())
  sendRedirect(ctx, "/reviews")


proc setupRoutes*(app: var Prologue, store: ContentStore, db: DbConn, cfg: SiteConfig = defaultSiteConfig) =
  app.use(staticFileMiddleware(@["public"]))

  app.get("/", proc(ctx: Context) {.async.} = await home(ctx, store, cfg))

  app.get("/blog", proc(ctx: Context) {.async.} = await blog(ctx, store, cfg))
  app.get("/blog/{slug}", proc(ctx: Context) {.async.} = await blog_slug(ctx, store, cfg))

  app.get("/projects", proc(ctx: Context) {.async.} = await projects(ctx, store, cfg))
  app.get("/projects/{slug}", proc(ctx: Context) {.async.} = await projects_slug(ctx, store, cfg))

  # Auth
  app.get("/vault-login", proc(ctx: Context) {.async.} = await sec_vault_login(ctx, cfg))
  app.post("/api/login",    proc(ctx: Context) {.async.} = await loginHandler(ctx, db))
  app.post("/api/register", proc(ctx: Context) {.async.} = await registerHandler(ctx, db))
  app.get("/api/logout", proc(ctx: Context) {.async.} =
    ctx.response.setCookie("token", "", path = "/", httpOnly = true, maxAge = some(0))
    sendRedirect(ctx, "/vault-login")
  )

  # Vault page + API
  app.get("/vault", proc(ctx: Context) {.async.} = await sec_vault(ctx, cfg))
  app.get("/api/vault-entries",         proc(ctx: Context) {.async.} = await apiVaultEntries(ctx, db))
  app.post("/api/vault-entries",        proc(ctx: Context) {.async.} = await apiAddVaultEntry(ctx, db))
  app.delete("/api/vault-entries/{id}", proc(ctx: Context) {.async.} = await apiDeleteVaultEntry(ctx, db))

  # Reviews
  app.get("/reviews",       proc(ctx: Context) {.async.} = await reviewsPage(ctx, db, cfg))
  app.post("/api/reviews",  proc(ctx: Context) {.async.} = await apiAddReview(ctx, db))
