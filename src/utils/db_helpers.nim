import db_connector/db_sqlite, bcrypt, std/strutils, std/sysrand

proc randomId(): int64 =
  var bytes: array[8, byte]
  discard urandom(bytes)
  copyMem(addr result, addr bytes[0], 8)
  result = result and 0x7FFFFFFFFFFFFFFF'i64  # keep positive

proc registerUser*(db: DbConn, username: string, password: string): bool =
  let salt = genSalt(10)
  let h = hash(password, salt)
  try:
    db.exec(sql"INSERT INTO users (id, username, password_hash) VALUES (?, ?, ?)", randomId(), username, h)
    return true
  except DbError:
    return false

proc checkUserPassword*(db: DbConn, username, password: string): bool =
  let row = db.getRow(sql"SELECT password_hash FROM users WHERE username = ?", username)
  if row[0] == "": return false
  let storedHash = row[0]
  # bcrypt: re-hash input with stored hash (which embeds the salt), then compare
  let rehashed = hash(password, storedHash)
  return compare(rehashed, storedHash)

proc getUserId*(db: DbConn, username: string): int64 =
  let row = db.getRow(sql"SELECT id FROM users WHERE username = ?", username)
  if row[0] == "": return -1
  return parseInt(row[0])

# ── Vault entries ──────────────────────────────────────────────────────────────

proc getVaultEntries*(db: DbConn, username: string): seq[Row] =
  return db.getAllRows(sql"""
    SELECT v.id, v.site, v.login, v.password_ciphertext
    FROM vaults v
    JOIN users u ON v.user_id = u.id
    WHERE u.username = ?
    ORDER BY v.site
  """, username)

proc addVaultEntry*(db: DbConn, username, site, login, ciphertext: string): bool =
  let userId = getUserId(db, username)
  if userId < 0: return false
  try:
    db.exec(sql"INSERT INTO vaults (id, user_id, site, login, password_ciphertext) VALUES (?, ?, ?, ?, ?)",
            randomId(), userId, site, login, ciphertext)
    return true
  except DbError:
    return false

proc deleteVaultEntry*(db: DbConn, username: string, entryId: string): bool =
  try:
    db.exec(sql"""
      DELETE FROM vaults WHERE id = ?
      AND user_id = (SELECT id FROM users WHERE username = ?)
    """, entryId, username)
    return true
  except DbError:
    return false

# ── Reviews ───────────────────────────────────────────────────────────────────

proc addReview*(db: DbConn, username, text: string): bool =
  try:
    db.exec(sql"INSERT INTO reviews (id, username, review_text) VALUES (?, ?, ?)", randomId(), username, text)
    return true
  except DbError:
    return false

proc getReviews*(db: DbConn): seq[Row] =
  return db.getAllRows(sql"SELECT username, review_text, created_at FROM reviews ORDER BY created_at DESC")