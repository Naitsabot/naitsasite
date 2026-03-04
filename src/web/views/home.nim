# Standard library imports
from std/sequtils import mapIt
from std/strutils import join
from std/tables import toTable
from std/xmltree import escape

# Local imports
import ../../content/types
import ../templates


proc viewHome*(title: string, blogs: seq[Document], projects: seq[Document]): string =
  let blogItems = blogs.mapIt(
    renderHTMLTemplate("src/web/templates/components/doc_list_item.html",
      {"url": "/blog/" & it.meta.slug, "title": xmltree.escape(it.meta.title)}.toTable)
  ).join("")
  let projectItems = projects.mapIt(
    renderHTMLTemplate("src/web/templates/components/doc_list_item.html",
      {"url": "/projects/" & it.meta.slug, "title": xmltree.escape(it.meta.title)}.toTable)
  ).join("")
  renderHTMLTemplate("src/web/templates/pages/home.html", {
    "title": xmltree.escape(title),
    "blogs": blogItems,
    "projects": projectItems,
  }.toTable)
