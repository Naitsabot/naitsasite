import std/sequtils
from std/strutils import join
import std/tables
import std/xmltree
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
