colors = require 'colors'
pad    = require 'pad'

module.exports = class Board

	constructor: ->
		if config.border.length > 1
			throw new Error 'The border configuration option only supports 1 character :('
		
		@title       = config.title
		@titleColor  = config.colors.title
		@border      = config.border
		@borderColor = config.colors.border

		colors.setTheme
			titleColor:  @titleColor
			borderColor: @borderColor
			highColor:   config.colors.high
			lowColor:    config.colors.low

		@draw()

	set: (column, label, value, high, low, increment) ->
		unless @data?
			@data = []
			@data.push [] for num in [1..config.columns]

		item = _.find @data[column], (item) => item.label is label
		
		unless item?
			@data[column].push { label: label, value: value, high: high, low: low }
		else
			unless increment?
				item.value = '222'
			else
				item.value = parseInt(item.value, 10) + parseInt(value, 10)

	draw: ->
		windowSize = process.stdout.getWindowSize()
		@width     = windowSize[0]
		@height    = windowSize[1] - 7 # todo: figure out why this is hardcoded to fit the screen

		@_drawBorder()
		@_drawTitle()

		for line in [0..@height]
			@_drawLine(line)

		@_drawBorder()

		process.stdin.resume()

	_drawBorder: ->
		console.log @_repeatText @width, @border.borderColor

	_drawTitle: ->
		@_drawBlankLine()
		@_drawTextInCenter @title, @titleColor
		@_drawBlankLine()

	_drawBlankLine: ->
		console.log @border.borderColor + @_repeatText(@width - 2, ' ') + @border.borderColor

	_drawTextInCenter: (content, color) ->
		halfSpace = (@width - 2 - content.length) / 2

		if halfSpace.toString().indexOf('.') > 0
			beginningSpace = Math.floor(halfSpace)
			endSpace       = Math.floor(halfSpace) + 1
		else
			beginningSpace = halfSpace
			endSpace       = halfSpace

		console.log @border.borderColor + @_repeatText(beginningSpace, ' ') + content[color] + @_repeatText(endSpace, ' ') + @border.borderColor

	_drawLine: (line) ->
		unless @data? then return @_drawBlankLine()

		text  = ''
		space = Math.floor(@width / (@data.length * 2))

		for column, index in @data
			if column[line]
				label    = column[line].label + ":"
				value    = " " + @_getValue(column[line])

				text += pad space, label, ' '

				if value.length > column[line].value.length + 1
					text += pad value, space + 10, ' '
				else
					text += pad value, space, ' '
			else
				text += pad space, '', ' '
				text += pad '', space, ' '

		text = @border.borderColor + text.substring(1, text.length)     # add the beginning border
		text = text.substring(0, text.length - 1) + @border.borderColor # add the end border

		console.log text

	_getValue: (item) ->
		if isNaN(item.value) then return item.value

		if item.value > parseFloat(item.high) then return item.value.highColor
		if item.value < parseFloat(item.low)  then return item.value.lowColor

		return item.value

	_repeatText: (num, char) ->
		new Array(num + 1).join(char) # + 1 accounts for the 0 based array
