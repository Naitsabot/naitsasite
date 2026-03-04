# Third-party imports
import prologue

# Local imports
import ./content/indexer
import ./utils/thumbs
import ./web/routes


proc main() =
    # Ensure thumbnails for all images
    ensureThumbnails("public/img", "public/thumbs")

    # Load all markdown content at startup
    let store = loadStore()

    var app = newApp(settings = newSettings(appName = "naitsasite"))
    setupRoutes(app, store)
    app.run()


when isMainModule:
    main()
