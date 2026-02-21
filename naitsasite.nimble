version       = "0.1.0"
author        = "Naitsabot"
description   = "Nim + Prologue site"
license       = "MIT"

requires "nim >= 2.2.6"
requires "prologue"
requires "yaml"
requires "markdown" # from https://github.com/soasme/nim-markdown (nimble name is commonly "markdown")

srcDir = "src"
bin    = @["app"]
