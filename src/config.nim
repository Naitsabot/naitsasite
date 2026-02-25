type
    CollectionConfig* = object
        name*: string        # "blog", "projects", ...
        dir*: string         # e.g. "content/blog"
        routePrefix*: string # e.g. "/blog"
        sortByDateDesc*: bool


    SiteConfig* = object
        siteTitle*: string
        baseUrl*: string # optional; useful later for RSS/sitemap
        collections*: seq[CollectionConfig]


const defaultSiteConfig* = SiteConfig(
    siteTitle: "NaitsaSite - Sebastian H. Lorenzen",
    baseUrl: "",
    collections: @[
        CollectionConfig(name: "blog", dir: "content/blog", routePrefix: "/blog", sortByDateDesc: true),
        CollectionConfig(name: "projects", dir: "content/projects", routePrefix: "/projects", sortByDateDesc: false)
    ]
)
