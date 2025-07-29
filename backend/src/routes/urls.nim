import prologue
import ./health, ./ping

proc applyAllRoutes*(app: var Prologue) =
    # Basic routes (no /api prefix)
    app.applyHealthRoutes()
    app.applyPingRoutes()
    
    # API v1 routes using group routing
    var apiV1 = newGroup(app, "/api/v1", @[])
    
    # Add API routes to the group
    # apiV1.get("/users", getUsersHandler)
    # apiV1.post("/users", createUserHandler)
    # apiV1.get("/users/{id}", getUserHandler)