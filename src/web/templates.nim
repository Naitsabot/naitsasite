from std/xmltree import escape 
import ../content/types

proc htmlLayout*(title: string, body: string): string =
  "<!doctype html>" &
  "<html lang='en'>" &
  "<head>" &
  "  <meta charset='utf-8'/>" &
  "  <meta name='viewport' content='width=device-width, initial-scale=1'/>" &
  "  <title>" & escape(title) & "</title>" &
  "  <link rel='stylesheet' href='/public/css/style.css'/>" &
  "</head>" &
  "<body>" &
  "  <header><nav>" &
  "    <a href='/'>Home</a> | " &
  "    <a href='/blog'>Blog</a> | " &
  "    <a href='/projects'>Projects</a>" &
  "  </nav></header>" &
  "  <main>" & body & "</main>" &
  "  <footer><small>Powered by Nim + Prologue</small></footer>" &
  "</body></html>"

proc docPage*(doc: Document): string =
  let head = "<h1>" & escape(doc.meta.title) & "</h1>"
  let meta =
    (if doc.meta.date.len > 0: "<p><small>" & escape(doc.meta.date) & "</small></p>" else: "")
  head & meta & doc.bodyHtml # bodyHtml is already HTML from markdown

proc docListItem*(collectionRoutePrefix: string, doc: Document): string =
  let url = collectionRoutePrefix & "/" & doc.meta.slug
  "<li><a href='" & escape(url) & "'>" & escape(doc.meta.title) & "</a></li>"
