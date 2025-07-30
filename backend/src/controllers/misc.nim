import std/[os, times, json, strutils, unicode, xmltree]
import prologue

import ../utils/[responses]


proc getHealthCheck*(ctx: Context) {.async.} =
    ## Health check endpoint - returns system status
    let healthData = %*{
        "status": "ok",
        "timestamp": $now(),
        "version": "1.0.0",
        "uptime": "TODO: calculate uptime",
        "database": "connected"  # TODO: check DB connection here
    }
    
    resp jsonResponse(healthData)


proc getDetailedHealth*(ctx: Context) {.async.} =
    ## More detailed health check with system info
    let detailedData = %*{
        "status": "ok",
        "timestamp": $now(),
        "version": "1.0.0",
        "services": {
            "database": "connected", # TODO: check DB connection here
            "cache": "connected", # TODO: check DB connection here
            "external_api": "connected" # TODO: check DB connection here
        },
        "system": {
            "memory_usage": "TODO: get memory info",
            "cpu_usage": "TODO: get CPU info"
        }
    }
    
    resp jsonResponse(detailedData)


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


proc getFavicon*(ctx: Context) {.async.} =
    await ctx.staticFileResponse("nanna.png", $getCurrentDir() & "/src/static")