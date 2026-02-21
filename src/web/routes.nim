import prologue
import prologue/middlewares/staticfile
from std/xmltree import escape 

import ../config
import ../content/indexer
import ../content/types
import ./templates
from ../utils/seqs import head

proc home(ctx: Context, store: ContentStore, cfg: SiteConfig) {.async.} =
  let latest = listCollection(store, "blog").head(5)

  var body = "<h1>" & escape(cfg.siteTitle) & "</h1>" &
              "<p>This is the homepage skeleton. Edit <code>src/web/templates.nim</code> later.</p>" &
              "<h2>Latest posts</h2><ul>"

  for d in latest:
    body.add docListItem("/blog", d)
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

proc setupRoutes*(app: var Prologue, store: ContentStore, cfg: SiteConfig = defaultSiteConfig) =
  # Serve static files (css, images, etc.)
  app.use(staticFileMiddleware("public", "/public"))

  app.get("/", proc(ctx: Context) {.async.} = await home(ctx, store, cfg))

  app.get("/blog", proc(ctx: Context) {.async.} = await blog(ctx, store, cfg))
  app.get("/blog/{slug}", proc(ctx: Context) {.async.} = await blog_slug(ctx, store, cfg))
  
  app.get("/projects", proc(ctx: Context) {.async.} = await projects(ctx, store, cfg))
  app.get("/projects/{slug}", proc(ctx: Context) {.async.} = await projects_slug(ctx, store, cfg))