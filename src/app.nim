# Local imports
import ./content/indexer
import ./content/types
import ./utils/thumbs

when defined(static):
    # Local imports
    import ./web/build
else:
    # Third-party imports
    import prologue

    # Local imports
    import ./web/routes


proc main() =
    # Ensure thumbnails for all images
    ensureThumbnails("public/img")

    # Load all markdown content at startup
    let store: ContentStore = loadStore()

    when defined(static):
        build(store)
    else:
        var app: Prologue = newApp(settings = newSettings(appName = "naitsasite"))
        setupRoutes(app, store)
        app.run()


when isMainModule:
    main()
