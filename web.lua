require "xavante"
require "xavante.cgiluahandler"
require "xavante.filehandler"
require "xavante.redirecthandler"

local port = tonumber(... or 9090)

xavante.HTTP {
    server = { host = "*", port = port },
    defaultHost = {
        rules = {
            {
                match = { "movies.lp" },
                with = xavante.cgiluahandler.makeHandler(".")
            },
            {
                match = "^/$",
                with = xavante.redirecthandler,
                params = { "movies.lp" }
            },
            {
                match = "js/.",
                with = xavante.filehandler,
                params = { baseDir = "." }
            }
        }
    }
}

xavante.start()
