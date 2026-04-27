# Standard library imports
import std/tables
from std/algorithm import sort
from std/options import Option, none, some

# Local imports
import ../config
import ./markdown_loader
import ./types


proc sortIfNeeded(docs: var seq[Document], sortByDateDesc: bool) =
    if not sortByDateDesc: return
    # Date is a string for now; ISO-8601 "YYYY-MM-DD" sorts correctly lexicographically.
    docs.sort(proc (a, b: Document): int =
        system.cmp(b.meta.date, a.meta.date)
    )


proc loadStore*(cfg: SiteConfig = defaultSiteConfig): ContentStore =
    var all: seq[Document] = @[]

    for c in cfg.collections:
        var colDocs: seq[Document] = loadCollection(c.name, c.dir)
        sortIfNeeded(colDocs, c.sortByDateDesc)
        all.add colDocs

    var idx: Table[system.string, system.int] = initTable[string, int]()
    for i, d in all.pairs:
        idx[key(d.collection, d.meta.slug)] = i

    ContentStore(docs: all, byKey: idx)


proc findDoc*(store: ContentStore, collection, slug: string): Option[Document] =
    let k: string = key(collection, slug)
    if store.byKey.hasKey(k):
        return some(store.docs[store.byKey[k]])
    none(Document)


proc listCollection*(store: ContentStore, collection: string, includeDrafts = false): seq[Document] =
    for d in store.docs:
        if d.collection == collection and (includeDrafts or not d.meta.draft):
            result.add d
