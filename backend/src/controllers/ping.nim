import std/[times, json, strutils, unicode, xmltree]
import prologue

import ../utils/[responses]


proc getPing*(ctx: Context) {.async.} =
    resp plainTextResponse("pong!")


proc getPingFormatted*(ctx: Context) {.async.} =
    let format: string = ctx.getPathParams("format", "txt").toLower()

    if "txt" in format:
        resp plainTextResponse("pong!")
    elif "text" in format:
        resp plainTextResponse("pong!")
    elif "json" in format:
        let json: JsonNode = %* {"message": "pong!", "timestamp": $now() }
        resp jsonResponse(json)
    elif "xml" in format:
        let msg = newElement("message")
        msg.add(newText("pong!"))
        let time = newElement("timestamp") 
        time.add(newText($now()))
        let xml = newXmlTree("response", [msg, time])
        resp xmlResponse(xml)
    else:
        resp plainTextResponse("Unknown format") 
