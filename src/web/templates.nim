# Standard library imports
import std/tables
from std/strutils import replace
from std/xmltree import escape


proc renderHTMLTemplate*(templatePath: string, vars: Table[string, string] = initTable[string, string]()): string =
  var temp = readFile(templatePath)
  for key, value in vars:
    temp = temp.replace("{{" & key & "}}", value)
  result = temp


proc htmlLayout*(title: string, body: string, toc: string = ""): string =
  renderHTMLTemplate("src/web/templates/doc.html", {
    "meta": renderHTMLTemplate("src/web/templates/head.html", {"title": escape(title)}.toTable()),
    "body": renderHTMLTemplate("src/web/templates/filters.html") &
            renderHTMLTemplate("src/web/templates/header.html") &
            renderHTMLTemplate("src/web/templates/main.html", {"body": body, "toc": toc}.toTable()) &
            renderHTMLTemplate("src/web/templates/footer.html") &
            renderHTMLTemplate("src/web/templates/overlay.html")
  }.toTable())
