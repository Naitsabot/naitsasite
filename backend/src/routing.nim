import jester

proc defineRoutes*() = 
    routes:
        get "/":
            resp "Hello, World!"
        get "/ping":
            resp "pong!"
