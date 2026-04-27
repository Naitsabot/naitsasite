from os import `/`, dirExists, splitFile, walkFiles
from std/sequtils import filterIt, mapIt
from std/strutils import find, split, splitLines, startsWith, strip, toLowerAscii
import std/tables

# Third-party imports
import markdown
import yaml

# Local imports
import ./types


proc splitFrontMatter(raw: string): (string, string) =
  if not raw.startsWith("---\n"):
    return ("", raw)

  let delim: string = "\n---\n"
  let idx: int = raw.find(delim, start = 4)
  if idx < 0:
    return ("", raw)

  let yamlText: string = raw[4 ..< idx]
  let body: string = raw[(idx + delim.len) .. ^1]
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
  let r: tuple[ok: bool, v: YamlNode] = mapGet(y, k)
  if r.ok:
    let s: string = nodeAsStr(r.v)
    if s.len > 0: return s
  default


proc getBool(y: YamlNode, k: string, default = false): bool =
  let s: string = getStr(y, k, "")
  if s.len == 0: return default
  s.toLowerAscii() in ["true", "yes", "1", "on"]


proc getTags(y: YamlNode, k: string): seq[string] =
  let r: tuple[ok: bool, v: YamlNode] = mapGet(y, k)
  if not r.ok: return @[]
  let n: YamlNode = r.v
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
  result.gitlinks = getTags(root, "gitlinks")


proc isAsciiAlphaNum(ch: char): bool =
  (ch >= 'a' and ch <= 'z') or (ch >= '0' and ch <= '9')


proc slugifyHeading(text: string, used: var Table[string, int]): string =
  var base = newStringOfCap(text.len)
  var prevDash: bool = false
  for ch in text.toLowerAscii():
    if isAsciiAlphaNum(ch):
      base.add ch
      prevDash = false
    else:
      if not prevDash and base.len > 0:
        base.add '-'
        prevDash = true

  base = base.strip(chars = {'-'})
  if base.len == 0:
    base = "section"

  if not used.hasKey(base):
    used[base] = 1
    return base

  used[base] = used[base] + 1
  base & "-" & $used[base]


proc extractToc(bodyMd: string): seq[types.TocItem] =
  var usedIds: Table[system.string, system.int] = initTable[string, int]()
  var inFence: bool = false
  var fenceMarker: string = ""

  for line in bodyMd.splitLines():
    let trimmed: string = line.strip()
    if trimmed.len >= 3 and (trimmed.startsWith("```") or trimmed.startsWith("~~~")):
      let marker: string = trimmed[0..2]
      if not inFence:
        inFence = true
        fenceMarker = marker
      elif marker == fenceMarker:
        inFence = false
      continue

    if inFence:
      continue

    let lead: string = line.strip(leading = true, trailing = false)
    if lead.len == 0 or lead[0] != '#':
      continue

    var level: int = 0
    while level < lead.len and lead[level] == '#':
      inc level

    if level == 0 or level > 6:
      continue
    if level >= lead.len or lead[level] != ' ':
      continue

    var text: string = lead[(level + 1) .. ^1].strip()
    text = text.strip(chars = {'#', ' '})
    if text.len == 0:
      continue

    let id: string = slugifyHeading(text, usedIds)
    result.add types.TocItem(level: level, text: text, id: id)


proc replaceFirst(s: string, sub: string, by: string): string =
  let idx = s.find(sub)
  if idx < 0:
    return s
  s[0 ..< idx] & by & s[(idx + sub.len) .. ^1]


proc applyHeadingIds(html: string, items: seq[types.TocItem]): string =
  var output: string = html
  for item in items:
    let tag: string = "<h" & $item.level & ">"
    let tagWithId: string = "<h" & $item.level & " id=\"" & item.id & "\">"
    output = replaceFirst(output, tag, tagWithId)
  output


proc loadDocument*(collection: string, filePath: string): types.Document =
  let raw: string = readFile(filePath)
  let (yamlText, bodyMd) = splitFrontMatter(raw)

  let slugFallback: string = filePath.splitFile.name
  let titleFallback: string = slugFallback

  let meta: DocumentMeta = parseMeta(yamlText, slugFallback, titleFallback)
  let tocItems: seq[TocItem] = extractToc(bodyMd)
  let html: string = applyHeadingIds(markdown(bodyMd), tocItems)

  types.Document(
    meta: meta,
    collection: collection,
    bodyHtml: html,
    toc: tocItems,
    rawMarkdown: bodyMd,
    sourcePath: filePath
  )


proc loadCollection*(collection: string, dir: string): seq[types.Document] =
  if not dirExists(dir):
    return @[]
  for filePath in walkFiles(dir / "*.md"):
    result.add loadDocument(collection, filePath)
