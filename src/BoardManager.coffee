keypress = require 'keypress'
Board    = require './Board'

module.exports = class BoardManager

	setupDefaultBoard: ->
		@_addBoard  'default'
		@_drawBoard 'default'
		@_manageInput()

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
			
			if key.ctrl and key.name is 'c'
				process.exit()

			if key.name is 'escape'
				@_drawBoard 'default'

			if @_findBoardByKey key.name
				@_drawBoard key.name

		process.stdin.setRawMode true
		process.stdin.resume()
