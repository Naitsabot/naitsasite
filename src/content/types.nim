import std/tables


type
    DocumentMeta* = object
        title*: string
        date*: string        # keep as string for now; upgrade to DateTime later
        slug*: string
        tags*: seq[string]
        draft*: bool
        summary*: string
        gitlinks*: seq[string]

    Document* = object
        meta*: DocumentMeta
        collection*: string  # "blog" or "projects"
        bodyHtml*: string
        rawMarkdown*: string
        sourcePath*: string

    ContentStore* = object
        # All docs loaded (both blog and projects, etc.)
        docs*: seq[Document]
        # Quick lookup by "collection/slug"
        byKey*: Table[string, int]  # key -> index in docs


proc key*(collection, slug: string): string =
    collection & "/" & slug
