express = require 'express'
Board   = require './Board'

module.exports = class Server

	start: ->
		board = new Board

		app = express()
		app.use express.bodyParser()

		app.post '/', (req, resp) =>
			column = req.param 'column', null
			label  = req.param 'label', null
			value  = req.param 'value', null
			high   = req.param 'high', null
			low    = req.param 'low', null

			board.set column, label, value, high, low
			board.draw()

			resp.send 'OK'

		app.listen(config.server.port)
