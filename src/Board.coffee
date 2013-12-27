colors      = require 'colors'
pad         = require 'pad'
PollManager = require './PollManager'

module.exports = class Board

	constructor: (@boardManager) ->
		if config.border.length > 1
			throw new Error 'The border configuration option only supports 1 character :('

		process.on 'SIGWINCH', => 
			@draw()

	set: (parameters) ->
		unless @data?
			@data = []
			@data.push [] for num in [1..config.columns]
		
		if (!parameters.value? and !parameters.poll_url?) or parameters.value?
			@_createOrUpdateDataPoint parameters
		else
			poller = new PollManager
				parameters: parameters
				update:     (parameters) => @_createOrUpdateDataPoint parameters

	_createOrUpdateDataPoint: (parameters) ->
		item = _.find @data[parameters.column], (item) =>
			unless item.label? then return null
			return item.label is parameters.label

		if item?
			if parameters.value is 'increment'
				item.value = parseFloat(item.value) + 1
			else if parameters.value is 'decrement'
				item.value = parseFloat(item.value) - 1
			else
				item.value = parameters.value
		else
			@data[parameters.column].push parameters

		if @boardManager.activeBoard is @ then @draw()
		 
	draw: ->
		windowSize = process.stdout.getWindowSize()
		@width     = windowSize[0]
		@height    = windowSize[1] - 7 # todo: figure out why this is hardcoded to fit the screen

		if @width < 115
			console.log 'Sorry, the width of your terminal must be atleast 115. There is no need to restart hubble, it will redraw when the terminal is large enough. :)'.red
			return

		@drawBuffer = ''

		@_drawBorder()
		@_drawTitle()

		if config.banner?
			@height = @height - 2
			@_drawBlankLine()
			@_addToDrawBuffer config.border[config.colors.border] + @_getLineTextInCenter(@width - 2, config.banner.text, config.banner.color) + config.border[config.colors.border]

		for line in [0..@height]
			@_drawLine(line)

		@_drawBorder()

		console.log @drawBuffer

	_addToDrawBuffer: (value) ->
		@drawBuffer += value

	_drawBorder: ->
		@_addToDrawBuffer @_repeatText @width, config.border[config.colors.border]

	_drawTitle: ->
		@_drawBlankLine()
		@_addToDrawBuffer config.border[config.colors.border] + @_getLineTextInCenter(@width - 2, config.title, config.colors.title) + config.border[config.colors.border]
		@_drawBlankLine()

	_drawBlankLine: ->
		@_addToDrawBuffer config.border[config.colors.border] + @_repeatText(@width - 2, ' ') + config.border[config.colors.border]

	_drawLine: (line) ->
		unless @data? then return @_drawBlankLine()

		text  = ''
		cellSpace = @width / (@data.length * 2)
		space     = Math.floor(cellSpace)

		for column, index in @data
			if column[line]
				unless column[line].value?
					unless column[line].label?
						text += pad space, '', ' '
						text += pad '', space, ' '
					else
						text += @_getLineTextInCenter space * 2, column[line].label
				else
					label = column[line].label + ":"
					value = " " + column[line].value

					text += pad space, label, ' '

					if parseFloat(value)
						if value > parseFloat(column[line].high) then value = value[config.colors.high]
						if value < parseFloat(column[line].low)  then value = value[config.colors.low]

					if value.length > column[line].value.toString().length + 1
						text += pad value, space + 10, ' '
					else
						text += pad value, space, ' '
			else
				text += pad space, '', ' '
				text += pad '', space, ' '

		text = @_fixLineSpacing(cellSpace, text)

		@_addToDrawBuffer config.border[config.colors.border] + text + config.border[config.colors.border]

	_fixLineSpacing: (cellSpace, text) ->
		remainder = cellSpace % 1

		if remainder is 0.75
			text = ' ' + text

		if remainder is 0.5 and config.columns is 1
			text = text.substring(1)

		if remainder is 0.25
			text = text.substring(1)
		
		if remainder is 0
			text = text.substring(1)
			text = text.substring(0, text.length - 1)

		return text

	_getLineTextInCenter: (width, content, color) ->
		halfSpace = (width - content.length) / 2

		if halfSpace.toString().indexOf('.') > 0
			beginningSpace = Math.floor(halfSpace)
			endSpace       = Math.floor(halfSpace) + 1
		else
			beginningSpace = halfSpace
			endSpace       = halfSpace

		if color?
			return @_repeatText(beginningSpace, ' ') + content[color] + @_repeatText(endSpace, ' ')
		else
			return @_repeatText(beginningSpace, ' ') + content + @_repeatText(endSpace, ' ')
	
	_repeatText: (num, char) ->
		new Array(num + 1).join(char) # + 1 accounts for the 0 based array
