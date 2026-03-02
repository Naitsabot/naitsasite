version       = "0.1.0"
author        = "Naitsabot"
description   = "Nim + Prologue site"
license       = "MIT"

requires "nim >= 2.2.6"
requires "db_connector"
requires "prologue"
requires "yaml"
requires "markdown" # from https://github.com/soasme/nim-markdown (nimble name is commonly "markdown")
requires "jwt"
requires "bcrypt"


srcDir = "src"
bin    = @["app"]
