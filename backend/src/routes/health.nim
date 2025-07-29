import prologue
import ../controllers/health

proc applyHealthRoutes*(app: var Prologue): auto =
    # Basic health check
    app.addroute("/health", getHealthCheck, HttpGet)
    
    # Detailed health check (maybe for internal monitoring)
    app.addroute("/health/detailed", getDetailedHealth, HttpGet)
