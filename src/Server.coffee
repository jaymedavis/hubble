express      = require 'express'
fs           = require 'fs'
bodyParser   = require 'body-parser'
BoardManager = require './BoardManager'
DiskManager  = require './DiskManager'

module.exports = class Server

	start: ->
		boardManager = new BoardManager

		app = express()

		app.use bodyParser()

		if process.argv[2]?
			diskManager = new DiskManager

			diskManager.load process.argv[2], (err, data) ->
				if err?
					console.log err
					process.exit()
					return

				boardManager.loadFromData data
		else
			boardManager.setupDefaultBoard()

		app.post '/', (req, resp) =>
			parameters =
				column:       req.body.column
				label:        req.body.label
				high:         req.body.high
				low:          req.body.low
				value:        req.body.value
				poll_url:     req.body.poll_url
				poll_seconds: req.body.poll_seconds
				poll_failed:  req.body.poll_failed
				poll_method:  req.body.poll_method
				poll_header:  req.body.poll_header
				screen:       req.body.screen

			if parameters.value? and (parameters.poll_url? or parameters.poll_seconds? or parameters.poll_failed?)
				resp.send 'you cannot set the value manually and also have it poll. it needs to do one or the other', 400
				return

			if parameters.screen? and parameters.screen.length > 1
				resp.send 'screen only supports 1 character', 400
				return

			boardManager.sendBoardData parameters

			resp.send 'OK'.green

		app.post '/save', (req, resp) =>
			parameters =
				filename: req.body.filename

			unless parameters.filename?
				resp.send 'cannot save without a filename', 400
				return

			diskManager = new DiskManager
			diskManager.save boardManager.boards, parameters.filename, (err) ->
				if err
					resp.send err, 400
				else
					resp.send 'OK'.green

		app.listen(config.server.port)
