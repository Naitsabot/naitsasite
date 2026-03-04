# Standard library imports
from os import `/`, execShellCmd, createDir, dirExists, fileExists, parentDir, relativePath, walkDirRec
from std/strutils import endsWith, join


proc generateThumbnail*(srcPath, destPath: string, width = 256, height = 256) =
  let cmd = "magick " & srcPath &
    " -resize " & $width & "x" & $height &
    " +dither -dither FloydSteinberg -remap palette.png " &
    destPath
  discard execShellCmd(cmd)


proc ensureThumbnails*(imgDir, thumbDir: string, width = 256, height = 256) =
  ## Example usage:
  ## ensureThumbnails("public/img", "public/thumbs")
  if not dirExists(thumbDir):
    createDir(thumbDir)

  for path in walkDirRec(imgDir):
    if path.endsWith(".png") or path.endsWith(".jpg") or path.endsWith(".jpeg"):
      let relPath: string = relativePath(path, imgDir)
      let thumbPath = thumbDir / relPath
      let thumbParent = thumbPath.parentDir()

      if not dirExists(thumbParent):
        createDir(thumbParent)

      if not fileExists(thumbPath):
        generateThumbnail(path, thumbPath, width, height)
