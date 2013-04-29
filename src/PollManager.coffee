request = require 'request'
jspath  = require 'jspath'
moment  = require 'moment'
pjson   = require '../package.json'

module.exports = class PollManager

	constructor: (@config) ->
		@config.parameters.value = 'initializing...'
		@config.update @config.parameters

		options =
			url:     @config.parameters.poll_url
			headers: []

		options.headers['User-Agent'] = "hubble #{pjson.version}"

		poll_headers = @config.parameters.poll_header
		if poll_headers?
			if typeof(poll_headers) is 'string'
				options.headers[poll_headers.split(":")[0].trim()] = poll_headers.split(":")[1].trim()
			else
				for header in poll_headers
					options.headers[header.split(":")[0].trim()] = header.split(":")[1].trim()

		setInterval =>
			request options, (err, response, body) =>
				if !err && response.statusCode is 200
					json = JSON.parse body
					
					@_setValueFromPollMethod json, @config.parameters.poll_method
				else
					@config.parameters.value = @config.parameters.poll_failed

				@config.update @config.parameters

		, @config.parameters.poll_seconds * 1000

	_setValueFromPollMethod: (json, method) ->
		if method is 'count_array'
			@config.parameters.value = json.length

		json_value_selector = 'json_value:'
		if method.substring(0, json_value_selector.length) is json_value_selector
			entry = jspath.apply method.substring(json_value_selector.length), json

			date = Date.parse(entry[0])

			if date and isNaN(entry[0])
				@config.parameters.value = moment(date).fromNow()
			else
				@config.parameters.value = entry[0]
