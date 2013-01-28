request = require 'request'

module.exports = class PollManager

	constructor: (@config) ->
		@config.parameters.value = 'initializing...'
		@config.update @config.parameters

		setInterval =>
			request @config.parameters.poll_url, (err, response, body) =>
				if !err && response.statusCode is 200
					json = JSON.parse body
					
					if @config.parameters.poll_method = 'count_array'
						@config.parameters.value = json.length
				else
					@config.parameters.value = @config.parameters.poll_failed

				@config.update @config.parameters

		, @config.parameters.poll_seconds * 1000
