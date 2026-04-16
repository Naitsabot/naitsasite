# Standard library imports
from std/sequtils import mapIt
from std/strutils import join
from std/tables import toTable
from std/xmltree import escape

# Local imports
import ../../content/types
import ../templates
import ./shared


proc viewBlogList*(posts: seq[Document], base: string = ""): string =
  let items: string = posts.mapIt(
    renderHTMLTemplate("src/web/templates/components/doc_list_item.html",
      {"url": base & "/blog/" & it.meta.slug, "title": escape(it.meta.title)}.toTable)
  ).join("")
  renderHTMLTemplate("src/web/templates/pages/blog_list.html", {"items": items}.toTable)


proc viewBlogPost*(doc: Document): tuple[body: string, toc: string] =
  result.body = renderHTMLTemplate("src/web/templates/pages/blog_post.html", {
    "title": escape(doc.meta.title),
    "date": renderDate(doc.meta.date),
    "gitlinks": renderGitLinks(doc.meta.gitlinks),
    "body": doc.bodyHtml,
  }.toTable)
  result.toc = renderToc(doc.toc)
