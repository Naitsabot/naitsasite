# Standard library imports
from std/sequtils import mapIt
from std/strutils import join
from std/tables import toTable
from std/xmltree import escape

# Local imports
import ../../content/types
import ../templates


proc renderGitLinks*(links: seq[string]): string =
  if links.len == 0: return ""
  let items = links.mapIt(
    renderHTMLTemplate("src/web/templates/components/gitlink.html", {"url": xmltree.escape(it)}.toTable)
  ).join("<br>")
  renderHTMLTemplate("src/web/templates/components/gitlinks.html", {"items": items}.toTable)


proc renderDate*(date: string): string =
  if date.len == 0: return ""
  renderHTMLTemplate("src/web/templates/components/doc_date.html", {"date": xmltree.escape(date)}.toTable)


proc renderToc*(items: seq[TocItem]): string =
  if items.len == 0: return ""
  let tocItems = items.mapIt(
    renderHTMLTemplate("src/web/templates/components/toc_item.html", {
      "id": xmltree.escape(it.id),
      "text": xmltree.escape(it.text),
      "level": $it.level,
    }.toTable)
  ).join("")
  renderHTMLTemplate("src/web/templates/components/toc.html", {"items": tocItems}.toTable)
