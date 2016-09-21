http        = require 'http'
_           = require 'lodash'
Bourse      = require 'bourse'

class CreateCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, username, password}

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?

    @bourse.createItem data, (error, results) =>
      return callback @_userError(422, 'data is required') unless data?
      return callback @_userError(422, 'Subject is required') unless data.itemSubject?
      return callback @_userError(422, 'Body is required') unless data.itemBody?
      return callback @_userError(422, 'Start time is required') unless data.itemStart?
      return callback @_userError(422, 'End time is required') unless data.itemEnd?
      return callback @_userError(422, 'Attendees are required') unless data.itemAttendees?
      return callback @_userError(422, 'Location is required') unless data.itemLocation?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: results
      }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = CreateCalendarItem
