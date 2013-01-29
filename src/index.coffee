Server = require './Server'

## globals
global.config = require "#{process.cwd()}/config"
global._      = require 'underscore'

server = new Server
server.start()
