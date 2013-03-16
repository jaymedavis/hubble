express      = require 'express'
BoardManager = require './BoardManager'

module.exports = class Server

	start: ->
		boardManager = new BoardManager

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
				return

			boardManager.sendBoardData parameters

			resp.send 'OK'

		app.listen(config.server.port)
