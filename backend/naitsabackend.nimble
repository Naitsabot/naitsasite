# Package

version       = "0.1.0"
author        = "naitsa"
description   = "Naitsas backend-app for Naitsasite"
license       = "Limfjordsporter"
srcDir        = "src"
bin           = @["naitsabackend"]


# Dependencies

requires "nim >= 2.2.2"
requires "prologue >= 0.6.6"


# Configuration

#srcDir        = "src"
#installExt    = @["nim"]  # File extensions to install


# Custom tasks

#task test, "Run the test suite":
#  exec "nim c -r tests/test_all"