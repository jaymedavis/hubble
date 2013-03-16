keypress = require 'keypress'
Board    = require './Board'

module.exports = class BoardManager

	constructor: ->
		@_addBoard  'default'
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
		unless @items?
			@items = []
		
		item = { name: "board-#{key}", board: new Board @ }
		@items.push item

		return item.board

	_drawBoard: (key) ->
		@activeBoard = @_findBoardByKey key
		@activeBoard.draw()

	_findBoardByKey: (key) ->
		name = "board-#{key}"
		item = _.find @items, (board) -> board.name is name

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
				console.log 'found it!'
				@_drawBoard key.name

		process.stdin.setRawMode true
		process.stdin.resume()
