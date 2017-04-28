http        = require 'http'
Bourse      = require 'bourse'
_           = require 'lodash'

class DeleteCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, username, password}
    @doSlow = _.throttle @do, 1000, {leading=false}

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required.') unless data?

    @bourse.deleteItem data, (error, results) =>
      return @_processError {error,data}, callback if error?
      return callback null, {
        metadata:
          code: 204
          status: http.STATUS_CODES[204]
      }

  _processError: ({error, data}, callback) =>
    return callback error if error.code < 500
    console.error "#{error.code}: #{error.message}"
    return @doSlow {data}, callback

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = DeleteCalendarItem
