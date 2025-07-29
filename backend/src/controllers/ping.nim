import prologue


proc getPing*(ctx: Context) {.async.} =
    resp plainTextResponse("pong!")
