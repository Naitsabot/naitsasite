import std/[os, strutils, logging]
import dotenv 

type 
    Environment* = enum
        Development = "development"
        Testing = "testing"
        Production = "production"

    DatabaseConfig* = object
        url*: string
        maxConnections*: int
        timeout*: int

    ServerConfig* = object
        host*: string
        port*: int
        debug*: bool
    
    SecurityConfig* = object
        jwtSecret*: string
        apiKey*: string
    
    LoggingConfig* = object
        level*: Level
        file*: string
        console*: bool
    
    AppConfig* = object
        appName*: string
        environment*: Environment
        server*: ServerConfig
        database*: DatabaseConfig
        security*: SecurityConfig
        logging*: LoggingConfig


var appConfig*: AppConfig


# Brugbare funktioner
proc isDevelopment*(): bool = appConfig.environment == Development
proc isProduction*(): bool = appConfig.environment == Production
proc isTesting*(): bool = appConfig.environment == Testing


proc getEnv*(key: string, default: string = ""): string =
    ## Get environment variable with optional default
    result = os.getEnv(key, default)
    if result.len == 0:
        result = default


proc getEnvBool*(key: string, default: bool = false): bool =
    ## Get boolean environment variable
    let value = getEnv(key).toLowerAscii()
    case value:
    of "true",  "1", "yes", "on":  true
    of "false", "0", "no",  "off": false
    else: default


proc getEnvInt*(key: string, default: int = 0): int =
    ## Get integer environment variable
    try:
        parseInt(getEnv(key, $default))
    except ValueError:
        default


proc parseLogLevel*(level: string): Level =
    ## Parse log level from string
    case level.toLowerAscii():
    of "debug":           lvlDebug
    of "info":            lvlInfo
    of "notice":          lvlNotice
    of "warn", "warning": lvlWarn
    of "error":           lvlError
    of "fatal":           lvlFatal
    else:                 lvlInfo


proc parseEnvironment*(env: string): Environment =
    ## Parse environment from string
    case env.toLowerAscii():
    of "development", "dev": Development
    of "testing",     "test": Testing
    of "production",  "prod": Production
    else: Development


proc loadConfig*(): AppConfig =
    ## Load configuration from environment variables
    
    # Load .env file if it exists
    if fileExists("/.env"):
        load("/.env")
        echo "Loaded /.env file"
    else:
        echo "Could not load .env from " & $getCurrentDir()
    
    # Load environment-specific .env file
    let envFile = "/.env." & getEnv("ENVIRONMENT", "development")
    if fileExists(envFile):
        overload(envFile)
        echo "Loaded " & envFile
    else:
        echo "Could not load " & envFile & " from " & $getCurrentDir()
    
    result = AppConfig(
        appName: getEnv("APP_NAME", "naitsabackendAPIdefaultname"),
        environment: parseEnvironment(getEnv("ENVIRONMENT", "development")),
        
        server: ServerConfig(
            host: getEnv("HOST", "127.0.0.1"),
            port: getEnvInt("PORT", 8080),
            debug: getEnvBool("DEBUG", true)
        ),
        
        database: DatabaseConfig(
            url: getEnv("DATABASE_URL", "sqlite:///src/database/dev.db"),
            maxConnections: getEnvInt("DB_MAX_CONNECTIONS", 10),
            timeout: getEnvInt("DB_TIMEOUT", 30)
        ),
        
        security: SecurityConfig(
            jwtSecret: getEnv("JWT_SECRET", "change-this-secret"),
            apiKey: getEnv("API_KEY", "")
        ),
        
        logging: LoggingConfig(
            level: parseLogLevel(getEnv("LOG_LEVEL", "info")),
            file: getEnv("LOG_FILE", "logs/app.log"),
            console: getEnvBool("LOG_CONSOLE", true)
        )
    )
    
    # Validate required configuration
    if result.security.jwtSecret == "change-this-secret" and result.environment == Production:
        raise newException(ValueError, "JWT_SECRET must be set in production")
    
    # Store globally for easy access
    appConfig = result


proc getConfig*(): AppConfig =
    return appConfig
