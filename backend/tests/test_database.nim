import ../src/config/[config, database]
import std/[logging]

proc testDatabase() =
    try:
        # Load config
        let config = loadConfig()
        echo "Testing database setup..."
        
        # Initialize database
        let db = initDatabase(config)
        echo "Database initialized successfully!"
        
        # Test a simple query
        let rows = executeQuery(sql"SELECT name FROM sqlite_master WHERE type='table'")
        echo "Tables in database:"
        for row in rows:
            echo "  - " & row[0]
        
        # Clean up
        closeDatabase()
        echo "Database test completed successfully!"
        
    except Exception as e:
        echo "Database test failed: " & e.msg

when isMainModule:
    testDatabase()