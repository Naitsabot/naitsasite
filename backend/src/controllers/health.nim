import std/[json, times]
import prologue


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
