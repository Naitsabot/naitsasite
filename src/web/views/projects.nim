# Standard library imports
from std/sequtils import mapIt
from std/strutils import join
from std/tables import toTable
from std/xmltree import escape

# Local imports
import ../../content/types
import ../templates
import ./shared


proc viewProjectsList*(docs: seq[Document]): string =
  let items = docs.mapIt(
    renderHTMLTemplate("src/web/templates/components/doc_list_item.html",
      {"url": "/projects/" & it.meta.slug, "title": xmltree.escape(it.meta.title)}.toTable)
  ).join("")
  renderHTMLTemplate("src/web/templates/pages/projects_list.html", {"items": items}.toTable)


proc viewProjectsPost*(doc: Document): tuple[body: string, toc: string] =
  result.body = renderHTMLTemplate("src/web/templates/pages/projects_post.html", {
    "title": xmltree.escape(doc.meta.title),
    "date": renderDate(doc.meta.date),
    "gitlinks": renderGitLinks(doc.meta.gitlinks),
    "body": doc.bodyHtml,
  }.toTable)
  result.toc = renderToc(doc.toc)
