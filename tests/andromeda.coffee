Board         = require '../src/Board'
BoardManager  = require '../src/BoardManager'
SocketServer  = require '../src/andromeda/SocketServer'

expect        = require('chai').expect

global.config = require "../src/configs/Andromeda"
global._      = require 'underscore'

describe 'andromeda', ->

	it 'should have the andromeda config loaded', ->
		expect(config.andromeda.port).to.equal 1550
	
	it 'should do something else', ->
		boardManager = new BoardManager

		board = new Board boardManager
		board.silent()

		server = new SocketServer board, 1550
