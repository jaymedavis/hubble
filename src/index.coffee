fs            = require 'fs'
Server        = require './Server'
WelcomeConfig = require './configs/Welcome'

## globals
global._      = require 'underscore'

# load config
fs.exists "#{process.cwd()}/config.coffee", (exists) ->
	if exists
		global.config = require "#{process.cwd()}/config"
	else
		global.config = WelcomeConfig

	server = new Server
	server.start()
