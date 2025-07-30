import prologue
import ../controllers/ping

proc applyPingRoutes*(app: var Prologue): auto =
    app.addRoute("/ping", getPing, HttpGet)
    app.addRoute("/ping/{format}", getPingFormatted, HttpGet)

