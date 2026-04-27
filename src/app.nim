# Third-party imports
import prologue

# Local imports
import ./content/indexer
import ./utils/thumbs
import ./web/routes
import ./content/types


proc main() =
    # Ensure thumbnails for all images
    ensureThumbnails("public/img")

    # Load all markdown content at startup
    let store: ContentStore = loadStore()

    var app: Prologue = newApp(settings = newSettings(appName = "naitsasite"))
    setupRoutes(app, store)
    app.run()


when isMainModule:
    main()
