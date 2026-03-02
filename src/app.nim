import prologue
import db_connector/db_sqlite

import ./content/indexer
import ./web/routes
import ./utils/thumbs
import ./utils/db_setup

proc main() =
    # Ensure thumbnails for all images
    ensureThumbnails("public/img", "public/thumbs")

    # Load all markdown content at startup
    let store = loadStore()

    # Open database and initialise schema
    var db = open("psw.db", "", "", "")
    initDb(db)

    var app = newApp(settings = newSettings(appName = "naitsasite"))
    setupRoutes(app, store, db)
    app.run()

when isMainModule:
    main()
