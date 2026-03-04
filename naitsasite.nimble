version       = "0.1.0"
author        = "Naitsabot"
description   = "Personal site written in Nim + Prologue"
license       = "MIT"

requires "nim >= 2.2.6" # https://nim-lang.org/
requires "prologue >= 0.6.8" # https://github.com/planety/Prologue
requires "yaml >= 2.2.1" # https://github.com/flyx/NimYAML 
requires "markdown >= 0.8.8" # https://github.com/soasme/nim-markdown

srcDir = "src"
bin    = @["app"]
