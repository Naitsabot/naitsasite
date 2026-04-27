# Standard Imports
import std/os

# Local imports
import ../content/indexer
import ../content/types
import ../config
import ./views/projects as projectsView
import ./views/blog as blogView
import ./views/home as homeView
import ./templates
from ../utils/seqs import head


const outDir: string = "dist"


proc writeOutput(path, content: string) =
    createDir(parentDir(path))
    writeFile(path, content)


proc build*(store: ContentStore, cfg: SiteConfig = defaultSiteConfig) =
    let latestBlogs = listCollection(store, "blog").head(5)
    let latestProjects = listCollection(store, "projects").head(5)
    writeOutput(outDir / "index.html", htmlLayout(cfg.siteTitle, viewHome(cfg.siteTitle, latestBlogs, latestProjects)))

    let posts = listCollection(store, "blog")
    writeOutput(outDir / "blog" / "index.html",
        htmlLayout("Blog - " & cfg.siteTitle, viewBlogList(posts)))
    for post in posts:
        let page = viewBlogPost(post)
        writeOutput(outDir / "blog" / post.meta.slug / "index.html",
            htmlLayout(post.meta.title & " - Blog - " & cfg.siteTitle, page.body, page.toc))

    let docs = listCollection(store, "projects")
    writeOutput(outDir / "projects" / "index.html",
        htmlLayout("Projects - " & cfg.siteTitle, viewProjectsList(docs)))
    for doc in docs:
        let page = viewProjectsPost(doc)
        writeOutput(outDir / "projects" / doc.meta.slug / "index.html",
            htmlLayout(doc.meta.title & " - Projects - " & cfg.siteTitle, page.body, page.toc))

    copyDir("public", outDir / "public")