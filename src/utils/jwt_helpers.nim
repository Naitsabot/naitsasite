import jwt, times, std/json, std/tables

# JWT secret key (must be kept safe)
const jwtSecret = "9kO0ap6qo6lRe8amnZzcIp1ogKFmntirqoPjHm9atnUvmSNws1sEMC7lBHjtiwzx59c22VaBQrW7GoPKqBoei7SwYKbAQZdY"


proc sign*(userId: string): string =
  var token = toJWT(%*{
    "header": {
      "alg": "HS256",
      "typ": "JWT"
    },
    "claims": {
      "userId": userId,
      "exp": (getTime() + 1.days).toUnix()
    }
  })
  token.sign(jwtSecret)
  result = $token


proc verify*(tokenStr: string): bool =
  try:
    let jwtToken = tokenStr.toJWT()
    result = jwtToken.verify(jwtSecret, HS256)
  except:
    result = false


proc decode*(tokenStr: string): string =
  let jwtToken = tokenStr.toJWT()
  result = jwtToken.claims["userId"].node.getStr()