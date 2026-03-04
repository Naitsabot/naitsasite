import std/tables
import ../templates

proc viewNotFound*(message: string): string =
  renderHTMLTemplate("src/web/templates/pages/not_found.html", {"message": message}.toTable)
