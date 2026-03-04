# Third-party imports
import prologue
import prologue/middlewares/staticfile

# Local imports
import ../config
import ../content/indexer
import ../content/types
import ./templates
import ./views/blog as blogView
import ./views/error as errorView
import ./views/home as homeView
import ./views/projects as projectsView
from ../utils/seqs import head


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


proc setupRoutes*(app: var Prologue, store: ContentStore, cfg: SiteConfig = defaultSiteConfig) =
  app.use(staticFileMiddleware(@["public"]))
  
  app.get("/favicon.ico", redirectTo("public/favicon.png"))
  app.get("/robots.txt", redirectTo("public/robots.txt"))
  app.get("/sitemap.xml", redirectTo("public/sitemap.xml"))

  app.get("/", proc(ctx: Context) {.async.} = await home(ctx, store, cfg))

  app.get("/blog", proc(ctx: Context) {.async.} = await blog(ctx, store, cfg))
  app.get("/blog/{slug}", proc(ctx: Context) {.async.} = await blog_slug(ctx, store, cfg))

  app.get("/projects", proc(ctx: Context) {.async.} = await projects(ctx, store, cfg))
  app.get("/projects/{slug}", proc(ctx: Context) {.async.} = await projects_slug(ctx, store, cfg))
