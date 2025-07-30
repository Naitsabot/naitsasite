import std/[logging, os]
import ./config


var 
    fileLogger*: FileLogger
    consoleLogger*: ConsoleLogger


proc setupLogging*(config: AppConfig) =
    ## Setup logging based on configuration
    
    # Create logs directory if it doesn't exist
    let logDir = config.logging.file.splitFile().dir
    if not dirExists(logDir):
        createDir(logDir)
    
    # Setup file logger
    fileLogger = newFileLogger(
        config.logging.file,
        levelThreshold = config.logging.level,
        fmtStr = "[$date] [$time] [$levelname] "
    )
    
    # Setup console logger if enabled
    if config.logging.console:
        consoleLogger = newConsoleLogger(
            levelThreshold = config.logging.level,
            fmtStr = "[$time] [$levelname] "
        )
    
    # Add loggers to the logging system
    addHandler(fileLogger)
    if config.logging.console:
        addHandler(consoleLogger)
    
    # Set global log level
    setLogFilter(config.logging.level)
    
    info("Logging initialized - Level: " & $config.logging.level & 
         ", File: " & config.logging.file)


proc closeLogging*() =
    ## Clean up logging
    if fileLogger != nil:
        fileLogger.file.close()
