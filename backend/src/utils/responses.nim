import std/[mimetypes, xmltree]
import prologue

func xmlResponse*(text: XmlNode, code = Http200, headers = initResponseHeaders(),
                   version = HttpVer11): Response {.inline.} =
    let m: MimeDB = newMimetypes()
    result = initResponse(version, code, headers, body = $text)
    result.headers["Content-Type"] = m.getMimetype("xml")