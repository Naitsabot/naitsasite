proc head*[T](s: openArray[T], n: int): seq[T] =
  result = @[]
  let m = min(n, s.len)
  for i in 0..<m:
    result.add s[i]