Bourse      = require 'bourse'
http        = require 'http'
_           = require 'lodash'

class GetCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, username, password}

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required.') unless data?
    return callback @_userError(422, 'data.itemId is required.') unless data.itemId?

    @bourse.getItemByItemId data.itemId, (error, response) =>
      return callback error if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: response
      }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = GetCalendarItem
