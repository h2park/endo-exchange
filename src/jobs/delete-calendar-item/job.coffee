http        = require 'http'
_           = require 'lodash'
Bourse      = require 'bourse'

class DeleteCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, username, password}

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?
    @bourse.deleteCalendarItem data, (error, results) =>
      return callback error if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: results.Envelope.Body.CreateItemResponse.ResponseMessages.CreateItemResponseMessage
      }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = DeleteCalendarItem
