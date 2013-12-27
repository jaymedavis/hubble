fs           = require 'fs'
keypress     = require 'keypress'
Board        = require './Board'
DiskManager  = require './DiskManager'
SocketServer = require './andromeda/SocketServer'

module.exports = class BoardManager

	setupDefaultBoard: ->
		board = @_addBoard 'default'

		configPath = "#{process.cwd()}/config.coffee"

		fs.exists configPath, (exists) =>
			if exists then return

			board.set { column: 0 }
			board.set { column: 0 }
			board.set { column: 0, label: 'Press Y to create an empty board' }
			board.set { column: 0 }
			board.set { column: 0, label: 'Press A to create a simple websocket server, Andromeda'  }
			board.set { column: 0 }
			board.set { column: 0, label: 'Press Q to quit' }

		@_drawBoard 'default'
		@_manageInput()

		fs.exists configPath, (exists) =>
			unless exists then return

			config = require "#{process.cwd()}/config"

			if config?.andromeda?
				new SocketServer board, config.andromeda.port

	loadFromData: (data) ->
		data = JSON.parse data

		for board in _.keys(data)
			newBoard = @_addBoard board

			for entry in data[board].data
				newBoard.set entry

		@_drawBoard 'default'
		@_manageInput()

	sendBoardData: (parameters) ->
		board = @_findBoardByKey 'default'

		if parameters.screen?
			board = @_findBoardByKey parameters.screen

			unless board?
				board = @_addBoard parameters.screen

		board.set parameters
		
		if board is @activeBoard then board.draw()

	_addBoard: (key) ->
		unless @boards?
			@boards = []
		
		item = { name: "board_#{key}", board: new Board @ }
		@boards.push item

		return item.board

	_drawBoard: (key) ->
		@activeBoard = @_findBoardByKey key
		@activeBoard.draw()

	_findBoardByKey: (key) ->
		name = "board_#{key}"
		item = _.find @boards, (board) -> board.name is name

		if item? then return item.board

	_manageInput: ->
		keypress process.stdin

		process.stdin.on 'keypress', (chunk, key) =>
			unless key? then return
			
			# todo: these could potentially clash with users screens
			if key.name is 'q'
				console.log ':('.cyan
				process.exit()

			if key.name is 'y'
				@_saveConfig 'Default'

			if key.name is 'a'
				@_saveConfig 'Andromeda'
			#end todo

			if key.ctrl and key.name is 'c'
				process.exit()

			if key.name is 'escape'
				@_drawBoard 'default'

			if @_findBoardByKey key.name
				@_drawBoard key.name

		process.stdin.setRawMode true
		process.stdin.resume()

	_saveConfig: (config) ->
		diskManager = new DiskManager
		diskManager.saveConfig config, (err) =>
			if err
				console.log err, 400
			else
				@boards = []
				global.config = require "#{process.cwd()}/config"
				@setupDefaultBoard()
