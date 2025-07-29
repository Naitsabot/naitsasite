import prologue
from ./routes/urls import applyAllRoutes

proc main() = 
    # Load configuration
    #loadConfig


    # Create Prologue app
    let
        env = loadPrologueEnv(".env")
        settings = newSettings(
            appName = env.getOrDefault("appName", "Prologue"), # TODO: use ocnfigs instead?
            debug = env.getOrDefault("debug", true), # TODO: use ocnfigs instead?
            port = Port(env.getOrDefault("port", 8080)), # TODO: use ocnfigs instead?
            #secretKey = env.getOrDefault("secretKey", "") # TODO: use ocnfigs instead?
        )

    # Create Prologue app
    var app: Prologue = newApp(settings = settings)


    # Add middleware (order matters!)
    #app.use(loggingMiddleware())
    #app.use(corsMiddleware())
    #app.use(authMiddleware())  # Apply to routes that need auth


    # Register routes (Basically middleware)
    # Be careful with the routes.
    app.applyAllRoutes()

    # Start server
    app.run()


when isMainModule:
    main()