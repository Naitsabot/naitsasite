# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import std/[asyncdispatch, os, strutils]
import jester
import routing

proc main() =
    defineRoutes()

when isMainModule:
    echo ""
    main()
