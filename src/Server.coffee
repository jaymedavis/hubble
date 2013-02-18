express       = require 'express'
keypress      = require 'keypress'
Board         = require './Board'

module.exports = class Server

	start: ->
		@_setupBoards()

		app = express()
		app.use express.bodyParser()

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
				screen:       req.body.screen

			if parameters.value? and (parameters.poll_url? or parameters.poll_seconds? or parameters.poll_failed?)
				resp.send 'you cannot set the value manually and also have it poll. it needs to do one or the other'
				return

			if parameters.screen? and parameters.screen.length > 1
				resp.send 'screen only supports 1 character'

			board = @boards['default']

			if parameters.screen?
				unless @boards[parameters.screen]?
					@boards[parameters.screen] = new Board

				board = @boards[parameters.screen]
			
			board.set parameters

			if board is @activeBoard then board.draw()

			resp.send 'OK'

		app.listen(config.server.port)
		@_manageInput()

	_setupBoards: ->
		@boards = []
		@boards['default'] = new Board
		@activeBoard = @boards['default']
		@activeBoard.draw()

	_manageInput: ->
		keypress process.stdin

		process.stdin.on 'keypress', (chunk, key) =>
			unless key? then return
			
			if key.ctrl and key.name is 'c'
				process.exit()

			if key.name is 'escape'
				@activeBoard = @boards['default']
				@activeBoard.draw()

			if @boards[key.name]
				@activeBoard = @boards[key.name]
				@activeBoard.draw()

		process.stdin.setRawMode true
		process.stdin.resume()
