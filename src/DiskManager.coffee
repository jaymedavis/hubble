cs = require 'coffeescript'
fs = require 'fs'

module.exports = class DiskManager

	saveConfig: (config, callback) ->
		configFile = __dirname + "/configs/#{config}.coffee"

		fs.readFile configFile, (err, data) ->
			if err then return callback(err)

			fs.writeFile "config.coffee", data, (err) ->
				if err then return callback(err)

				callback()

	save: (boards, filename, callback) ->
		newBoards = []

		for board in boards
			newBoards.push @_sanitizeBoard board

		fs.writeFile filename, @_convertBoardsToCoffeeScript(newBoards), (err) ->
			if err then return callback(err)

			callback()

	load: (filename, callback) ->
		fs.readFile filename, (err, data) ->
			if err then return callback(err)

			data = cs.compile data.toString(), bare: on
			data = data.trim()
			data = data.substring(1, data.length)     # strip off the ( from the beginning
			data = data.substring(0, data.length - 2) # stripe off the ); from the end

			callback null, data

	_sanitizeBoard: (board) ->
		newBoard =
			name: board.name.substring(6) # strip off board_
			data: []

		if board.board?.data?
			entries = board.board.data

			for entry in entries
				newBoard.data.push entry

		return newBoard

	_convertBoardsToCoffeeScript: (boards) ->
		coffee = ""

		for board in boards
			coffee += "\"#{board.name}\":\n"
			coffee += "\t\"data\": ["

			for column in board.data
				for entry, index in column
					coffee += "," if index > 0

					# this should not be done manually (dry) - think about sharing this logic with server.coffee
					coffee += "\n\t\t{"
					coffee += "\n\t\t\t\"column\":       #{entry.column}"
					coffee += "\n\t\t\t\"label\":        \"#{entry.label}\""       if entry.label?
					coffee += "\n\t\t\t\"high\":         #{entry.high}"            if entry.high?
					coffee += "\n\t\t\t\"low\":          #{entry.low}"             if entry.low?
					coffee += "\n\t\t\t\"value\":        \"#{entry.value}\""       if entry.value? and !entry.poll_url?
					coffee += "\n\t\t\t\"poll_url\":     \"#{entry.poll_url}\""    if entry.poll_url?
					coffee += "\n\t\t\t\"poll_seconds\": #{entry.poll_seconds}"    if entry.poll_seconds?
					coffee += "\n\t\t\t\"poll_failed\":  \"#{entry.poll_failed}\"" if entry.poll_failed?
					coffee += "\n\t\t\t\"poll_method\":  \"#{entry.poll_method}\"" if entry.poll_method?

					if entry.poll_header?
						if typeof(entry.poll_header) is 'string'
							coffee += "\n\t\t\t\"poll_header\":  \"#{entry.poll_header}\""
						else
							for header in entry.poll_header
								coffee += "\n\t\t\t\"poll_header\":  \"#{header}\""

					coffee += "\n\t\t\t\"screen\":       \"#{entry.screen}\""      if entry.screen?
					coffee += "\n\t\t}"

			coffee += "\n\t]\n"

		return coffee
