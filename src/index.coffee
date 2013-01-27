Server = require './Server'

## globals
global.config = require '../config'
global._      = require 'underscore'

server = new Server
server.start()
