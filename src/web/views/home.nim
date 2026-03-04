import std/sequtils
from std/strutils import join
import std/tables
import std/xmltree
import ../templates
import ../../content/types

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
