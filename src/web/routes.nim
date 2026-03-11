# Standard library imports
import std/[strutils, options, json]

# Third-party imports
import prologue
import prologue/middlewares/staticfile
import db_connector/db_sqlite

# Local imports
import ../config
import ../content/indexer
import ../content/types
import ./templates
import ../utils/jwt_helpers as jwtUtils
import ../utils/db_helpers
import ./views/blog as blogView
import ./views/error as errorView
import ./views/home as homeView
import ./views/projects as projectsView
import ./views/vault as vaultView
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
  resp htmlLayout(cfg.siteTitle, viewHome(cfg.siteTitle, latest_blogs, latest_projects))


proc blog(ctx: Context, store: ContentStore, cfg: SiteConfig) {.async.} =
  let posts = listCollection(store, "blog")
  resp htmlLayout("Blog - " & cfg.siteTitle, viewBlogList(posts))


proc blog_slug(ctx: Context, store: ContentStore, cfg: SiteConfig) {.async.} =
  let slug = ctx.getPathParams("slug")
  let found = findDoc(store, "blog", slug)
  if found.isSome:
    resp htmlLayout(found.get.meta.title & "- Blog - " & cfg.siteTitle, viewBlogPost(found.get))
  else:
    ctx.response.code = Http404
    resp htmlLayout("Not found", viewNotFound("Post not found."))


proc projects(ctx: Context, store: ContentStore, cfg: SiteConfig) {.async.} =
  let docs = listCollection(store, "projects")
  resp htmlLayout("Projects - " & cfg.siteTitle, viewProjectsList(docs))


proc projects_slug(ctx: Context, store: ContentStore, cfg: SiteConfig) {.async.} =
  let slug = ctx.getPathParams("slug")
  let found = findDoc(store, "projects", slug)
  if found.isSome:
    resp htmlLayout(found.get.meta.title & " - Projects - " & cfg.siteTitle, viewProjectsPost(found.get))
  else:
    ctx.response.code = Http404
    resp htmlLayout("Not found", viewNotFound("Project not found."))


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
  resp htmlLayout(cfg.siteTitle, vaultView.viewVaultLogin(notice))

proc sec_vault(ctx: Context, cfg: SiteConfig) {.async.} =
  if requireAuth(ctx).isNone:
    sendRedirect(ctx, "/vault-login")
    return
  resp htmlLayout(cfg.siteTitle, vaultView.viewVault())


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

proc vault_reviews(ctx: Context, db: DbConn, cfg: SiteConfig) {.async.} =
  let maybeUser = requireAuth(ctx)
  resp htmlLayout("Reviews - " & cfg.siteTitle, vaultView.viewVaultReviews(db, maybeUser))


proc apiAddReview(ctx: Context, db: DbConn) {.async.} =
  let maybeUser = requireAuth(ctx)
  if maybeUser.isNone:
    sendRedirect(ctx, "/vault-login")
    return
  let text = ctx.getPostParams("review_text")
  if text.strip().len == 0:
    sendRedirect(ctx, "/vault-reviews?error=empty")
    return
  discard addReview(db, maybeUser.get, text.strip())
  sendRedirect(ctx, "/vault-reviews")


proc setupRoutes*(app: var Prologue, store: ContentStore, db: DbConn, cfg: SiteConfig = defaultSiteConfig) =
  app.use(staticFileMiddleware(@["public"]))
  
  app.get("/favicon.ico", redirectTo("public/favicon.png"))
  app.get("/robots.txt", redirectTo("public/robots.txt"))
  app.get("/sitemap.xml", redirectTo("public/sitemap.xml"))

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
  app.get("/vault-reviews",       proc(ctx: Context) {.async.} = await vault_reviews(ctx, db, cfg))
  app.post("/api/vault-reviews",  proc(ctx: Context) {.async.} = await apiAddReview(ctx, db))
