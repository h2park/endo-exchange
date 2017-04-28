http        = require 'http'
Bourse      = require 'bourse'
_           = require 'lodash'

class GetCalendarItemsInRange
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, domain, username, password}
    @doSlow = _.throttle @do, 1000, {leading=false}

  do: ({data}, callback) =>
    return callback @_userError(422, 'Missing required parameter: data.start') unless _.has data, 'start'
    return callback @_userError(422, 'Missing required parameter: data.end') unless _.has data, 'end'

    {start, end} = data
    extendedProperties =
      'genisysMeetingId': true
      'genisysSearchableId': true

    @bourse.getCalendarItemsInRange {start, end, extendedProperties}, (error, items) =>
      return @_processError {error,data}, callback if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: items
      }

  _processError: ({error, data}, callback) =>
    return callback error if error.code < 500
    console.error "#{error.code}: #{error.message}"
    return @doSlow {data}, callback

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = GetCalendarItemsInRange
