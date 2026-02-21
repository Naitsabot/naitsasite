import std/[os, strutils, sequtils]

import yaml
import markdown # soasme/nim-markdown nimble package

import ./types

proc splitFrontMatter(raw: string): (string, string) =
  if not raw.startsWith("---\n"):
    return ("", raw)

  let delim = "\n---\n"
  let idx = raw.find(delim, start = 4)
  if idx < 0:
    return ("", raw)

  let yamlText = raw[4 ..< idx]
  let body = raw[(idx + delim.len) .. ^1]
  (yamlText, body)

proc mapGet(n: YamlNode, k: string): tuple[ok: bool, v: YamlNode] =
  if n.kind != yMapping:
    return (false, YamlNode())
  try:
    return (true, n[k])  # yaml/dom mapping index by string
  except CatchableError:
    return (false, YamlNode())

proc nodeAsStr(n: YamlNode): string =
  if n.kind == yScalar: n.content else: ""

proc getStr(y: YamlNode, k: string, default = ""): string =
  let r = mapGet(y, k)
  if r.ok:
    let s = nodeAsStr(r.v)
    if s.len > 0: return s
  default

proc getBool(y: YamlNode, k: string, default = false): bool =
  let s = getStr(y, k, "")
  if s.len == 0: return default
  s.toLowerAscii() in ["true", "yes", "1", "on"]

proc getTags(y: YamlNode, k: string): seq[string] =
  let r = mapGet(y, k)
  if not r.ok: return @[]
  let n = r.v
  case n.kind
  of ySequence:
    for item in n.elems:
      if item.kind == yScalar:
        result.add item.content.strip()
  of yScalar:
    result = n.content.split(',').mapIt(it.strip()).filterIt(it.len > 0)
  else:
    discard

proc parseMeta(yamlText, fallbackSlug: string, fallbackTitle: string): DocumentMeta =
  var root: YamlNode
  if yamlText.len > 0:
    load(yamlText, root)
  else:
    root = YamlNode()  # "empty node"

  result.title = getStr(root, "title", fallbackTitle)
  result.date = getStr(root, "date", "")
  result.slug = getStr(root, "slug", fallbackSlug)
  result.summary = getStr(root, "summary", "")
  result.draft = getBool(root, "draft", false)
  result.tags = getTags(root, "tags")

proc loadDocument*(collection: string, filePath: string): types.Document =
  let raw = readFile(filePath)
  let (yamlText, bodyMd) = splitFrontMatter(raw)

  let slugFallback = filePath.splitFile.name
  let titleFallback = slugFallback

  let meta = parseMeta(yamlText, slugFallback, titleFallback)
  let html = markdown(bodyMd)

  types.Document(
    meta: meta,
    collection: collection,
    bodyHtml: html,
    rawMarkdown: bodyMd,
    sourcePath: filePath
  )

proc loadCollection*(collection: string, dir: string): seq[types.Document] =
  if not dirExists(dir):
    return @[]
  for filePath in walkFiles(dir / "*.md"):
    result.add loadDocument(collection, filePath)