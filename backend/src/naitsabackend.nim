import std/[logging]
import prologue

import config/[config, database, logging]
import routes/[urls]

proc main() = 
    # Load configuration first
    let config = loadConfig()
    echo "Configuration loaded for environment: " & $config.environment
    
    # Setup logging
    setupLogging(config)
    info("Starting " & config.appName)
    
    # Initialize database connection
    discard initDatabase(config)
    info("Database initialized")
    
    # Create Prologue app
    let settings = newSettings(
        appName = config.appName,
        debug = config.server.debug,
        port = Port(config.server.port),
        address = config.server.host
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
