import db_connector/db_sqlite

proc initDb*(db: DbConn) =
  db.exec(sql"""
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY,
      username TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL
    );
  """)
  db.exec(sql"""
    CREATE TABLE IF NOT EXISTS vaults (
      id INTEGER PRIMARY KEY,
      user_id INTEGER NOT NULL,
      site TEXT NOT NULL,
      login TEXT NOT NULL,
      password_ciphertext TEXT NOT NULL,
      FOREIGN KEY(user_id) REFERENCES users(id)
    );
  """)
  db.exec(sql"""
    CREATE TABLE IF NOT EXISTS reviews (
      id INTEGER PRIMARY KEY,
      username TEXT NOT NULL,
      review_text TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  """)