# Standard library imports
from os import `/`, commandLineParams, copyFile, createDir, dirExists, fileExists, parentDir, relativePath, splitFile, walkDirRec
from std/parseopt import initOptParser, next, cmdEnd, cmdLongOption, cmdShortOption
from std/strutils import startsWith, strip

# Local imports
import ./config
import ./content/indexer
import ./utils/seqs
import ./utils/thumbs
import ./web/templates
import ./web/views/blog as blogView
import ./web/views/error as errorView
import ./web/views/home as homeView
import ./web/views/projects as projectsView


proc ensureDir(path: string) =
    if path.len == 0: return
    if not dirExists(path):
        createDir(path)


proc writePage(path: string, html: string) =
    ensureDir(path.parentDir())
    writeFile(path, html)


proc copyDir(srcDir, destDir: string) =
    if not dirExists(srcDir):
        return
    for path in walkDirRec(srcDir):
        if dirExists(path):
            continue
        let relPath = relativePath(path, srcDir)
        let outPath = destDir / relPath
        ensureDir(outPath.parentDir())
        copyFile(path, outPath)


proc copyRootFile(srcPath, destDir: string) =
    if not fileExists(srcPath):
        return
    let parts = splitFile(srcPath)
    let destPath = destDir / (parts.name & parts.ext)
    copyFile(srcPath, destPath)


proc normalizeBase(rawBase: string): string =
    if rawBase.len == 0:
        return ""
    if rawBase == ".":
        return "."
    var base = rawBase.strip(chars = {'/'})
    if base.len == 0:
        return ""
    if not base.startsWith("/"):
        base = "/" & base
    base


proc parseArgs(): tuple[outDir: string, base: string] =
    var outDir = "dist"
    var base = ""
    var useRelative = false

    var p = initOptParser(commandLineParams())
    while true:
        next(p)
        case p.kind
        of cmdLongOption, cmdShortOption:
            case p.key
            of "out", "o":
                outDir = p.val
            of "base", "b":
                base = p.val
            of "relative":
                useRelative = true
            else:
                discard
        else:
            discard
        if p.kind == cmdEnd:
            break

    if useRelative:
        base = "."

    (outDir: outDir, base: normalizeBase(base))


proc generateStaticSite(outDir: string, cfg: SiteConfig = defaultSiteConfig, base: string = "") =
    ensureDir(outDir)

    # Keep thumbnail generation consistent with dynamic mode.
    ensureThumbnails("public/img", "public/thumbs")

    let store = loadStore(cfg)

    let allBlogs = listCollection(store, "blog")
    let allProjects = listCollection(store, "projects")

    let latestBlogs = allBlogs.head(5)
    let latestProjects = allProjects.head(5)

    writePage(outDir / "index.html",
        htmlLayout(cfg.siteTitle, homeView.viewHome(cfg.siteTitle, latestBlogs, latestProjects, base), base = base))

    writePage(outDir / "blog" / "index.html",
        htmlLayout("Blog - " & cfg.siteTitle, blogView.viewBlogList(allBlogs, base), base = base))
    for doc in allBlogs:
        let page = blogView.viewBlogPost(doc)
        writePage(outDir / "blog" / doc.meta.slug / "index.html",
            htmlLayout(doc.meta.title & " - Blog - " & cfg.siteTitle, page.body, page.toc, base))

    writePage(outDir / "projects" / "index.html",
        htmlLayout("Projects - " & cfg.siteTitle, projectsView.viewProjectsList(allProjects, base), base = base))
    for doc in allProjects:
        let page = projectsView.viewProjectsPost(doc)
        writePage(outDir / "projects" / doc.meta.slug / "index.html",
            htmlLayout(doc.meta.title & " - Projects - " & cfg.siteTitle, page.body, page.toc, base))

    writePage(outDir / "404.html",
        htmlLayout("Not found", errorView.viewNotFound("Page not found."), base = base))

    copyDir("public", outDir / "public")
    copyRootFile("public/robots.txt", outDir)
    copyRootFile("public/sitemap.xml", outDir)
    copyRootFile("public/favicon.png", outDir)


when isMainModule:
    let args = parseArgs()
    generateStaticSite(args.outDir, base = args.base)
