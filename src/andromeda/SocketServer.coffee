websocket = require 'websocket'
http      = require 'http'

module.exports = class SocketServer

	constructor: (board, port) ->
		WebSocketServer = websocket.server

		httpServer = http.createServer (request, response) ->
			response.writeHead(404)
			response.end()

		httpServer.listen port, ->
			board.set { column: 0, label: "Server Status", value: "running server at #{port}" }
			board.set { column: 0 }
			board.set { column: 0, label: 'Total Connections', value: '0' }
			board.set { column: 0, label: 'Messages Sent', value: '0' }
			board.draw()

		wsServer = new WebSocketServer
			httpServer: httpServer
			autoAcceptConnections: false

		pool = []

		wsServer.on 'request', (request) ->
			connection = request.accept()
			pool.push connection

			board.set { column: 0, label: 'Total Connections', value: 'increment' }
			board.draw()

			connection.on 'message', (message) ->
				for conn in pool
					conn.sendUTF message.utf8Data

				board.set { column: 0, label: 'Messages Sent', value: 'increment' }

			connection.on 'close', (reason, description) ->
				board.set { column: 0, label: 'Total Connections', value: 'decrement' }
				board.draw()
