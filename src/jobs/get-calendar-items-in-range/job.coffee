http        = require 'http'
_           = require 'lodash'
Bourse      = require 'bourse'

class GetCalendarItemsInRange
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, domain, username, password}

  do: ({data}, callback) =>
    return callback @_userError(422, 'Missing required parameter: data.start') unless _.has data, 'start'
    return callback @_userError(422, 'Missing required parameter: data.end') unless _.has data, 'end'

    {start, end} = data
    extendedProperties =
      'X-genisys-meeting-id': true
      
    @bourse.getCalendarItemsInRange {start, end, extendedProperties}, (error, items) =>
      return callback error if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: items
      }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = GetCalendarItemsInRange
