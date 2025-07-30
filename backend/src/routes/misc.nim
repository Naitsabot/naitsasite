import prologue
import ../controllers/misc


proc applyMiscRoutes*(app: var Prologue): auto =
    app.addroute("/health", getHealthCheck, HttpGet)
    app.addroute("/health/detailed", getDetailedHealth, HttpGet)
    app.addRoute("/ping", getPing, HttpGet)
    app.addRoute("/ping/{format}", getPingFormatted, HttpGet)
    app.addRoute("/favicon.ico", getFavicon, HttpGet)
