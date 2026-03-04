import std/sequtils
from std/strutils import join
import std/tables
import std/xmltree
import ../templates
import ../../content/types
import ./shared

proc viewBlogList*(posts: seq[Document]): string =
  let items = posts.mapIt(
    renderHTMLTemplate("src/web/templates/components/doc_list_item.html",
      {"url": "/blog/" & it.meta.slug, "title": xmltree.escape(it.meta.title)}.toTable)
  ).join("")
  renderHTMLTemplate("src/web/templates/pages/blog_list.html", {"items": items}.toTable)

proc viewBlogPost*(doc: Document): string =
  renderHTMLTemplate("src/web/templates/pages/blog_post.html", {
    "title": xmltree.escape(doc.meta.title),
    "date": renderDate(doc.meta.date),
    "gitlinks": renderGitLinks(doc.meta.gitlinks),
    "body": doc.bodyHtml,
  }.toTable)
