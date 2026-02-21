import prologue

import ./content/indexer
import ./web/routes

proc main() =
    # Load all markdown content at startup
    let store = loadStore()

    var app = newApp(settings = newSettings(appName = "naitsasite"))
    setupRoutes(app, store)
    app.run()

when isMainModule:
    main()
