import std/[logging, os, strutils]
import ./config
import db_connector/db_sqlite


type
    Database* = ref object
        conn*: DbConn  # Uncomment when using a database
        isConnected*: bool


var db*: Database


# Migration system for SQLite
proc runMigrations*(database: Database) =
    ## Run database migrations
    info("Running database migrations...")
    
    try:
        # Create tasks table
        database.conn.exec(sql"""
            CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT DEFAULT '',
                completed BOOLEAN DEFAULT FALSE,
                due_date DATETIME,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Create an index on created_at for better query performance
        database.conn.exec(sql"""
            CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at)
        """)
        
        # Create an index on completed status
        database.conn.exec(sql"""
            CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed)
        """)
        
        info("Database migrations completed successfully")
        
    except Exception as e:
        error("Migration failed: " & e.msg)
        raise e


proc extractSqlitePath(url: string): string =
    ## Extract file path from sqlite:///path/to/file.db
    if url.startsWith("sqlite:///"):
        result = url[10..^1]  # Remove "sqlite:///"
    else:
        raise newException(ValueError, "Invalid SQLite URL format. Expected: sqlite:///path/to/file.db")


proc initDatabase*(config: AppConfig): Database =
    ## Initialize SQLite database connection
    result = Database(isConnected: false)
    
    let dbUrl = config.database.url
    info("Connecting to database: " & dbUrl)
    
    try:
        # Extract the file path from the URL
        let dbPath = extractSqlitePath(dbUrl)
        
        # Create database directory if it doesn't exist
        let dbDir = dbPath.splitFile().dir
        if not dirExists(dbDir):
            createDir(dbDir)
            info("Created database directory: " & dbDir)
        
        # Open SQLite connection
        result.conn = open(dbPath, "", "", "")
        result.isConnected = true
        info("SQLite database connected successfully: " & dbPath)
        
        # Run migrations
        runMigrations(result)
        
    except Exception as e:
        error("Failed to connect to database: " & e.msg)
        raise e
    
    db = result


# Helper procedures for database operations
proc closeDatabase*() =
    ## Close database connection
    if db != nil and db.isConnected:
        db.conn.close()
        db.isConnected = false
        echo "Database connection closed"


proc getDatabase*(): Database =
    ## Get the database instance
    if db == nil or not db.isConnected:
        raise newException(ValueError, "Database not initialized")
    return db


proc executeQuery*(query: SqlQuery, args: varargs[string, `$`]): seq[Row] =
    ## Execute a query and return results
    let database = getDatabase()
    return database.conn.getAllRows(query, args)


proc executeNonQuery*(query: SqlQuery, args: varargs[string, `$`]): bool =
    ## Execute a non-query (INSERT, UPDATE, DELETE) and return success status
    let database = getDatabase()
    try:
        database.conn.exec(query, args)
        return true
    except DbError:
        return false


proc executeNonQueryWithCount*(query: SqlQuery, args: varargs[string, `$`]): int =
    ## Execute a non-query and return number of affected rows using SQLite's changes()
    let database = getDatabase()
    database.conn.exec(query, args)
    
    # Use SQLite's built-in changes() function
    let rt = database.conn.getValue(sql"SELECT changes()")
    return parseInt(rt)


proc executeUpdate*(query: SqlQuery, args: varargs[string, `$`]): bool =
    ## Execute an UPDATE/DELETE and check if any rows were affected
    let database = getDatabase()
    
    # For UPDATE/DELETE, we can check the result differently
    try:
        database.conn.exec(query, args)
        # Query to see if changes() > 0
        let changesStr = database.conn.getValue(sql"SELECT changes()")
        return parseInt(changesStr) > 0
    except:
        return false


proc executeInsert*(query: SqlQuery, args: varargs[string, `$`]): bool =
    ## Execute an INSERT and verify it succeeded
    let database = getDatabase()
    
    try:
        database.conn.exec(query, args)
        return true
    except DbError as e:
        error("Insert failed: " & e.msg)
        return false


proc executeInsertWithId*(query: SqlQuery, args: varargs[string, `$`]): string =
    ## Execute an INSERT and return the last row ID (empty string if failed)
    let database = getDatabase()
    
    try:
        database.conn.exec(query, args)
        return database.conn.getValue(sql"SELECT last_insert_rowid()")
    except DbError:
        return ""
