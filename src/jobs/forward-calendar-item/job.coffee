http        = require 'http'
Bourse      = require 'bourse'
_           = require 'lodash'
async       = require 'async'

class ForwardCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, domain, username, password}

  do: (options, callback) =>
    retryOptions =
      tries: 10
      interval: 1000
      errorFilter: (error) =>
        console.error error
        return !(error.code < 500)

    async.retry retryOptions, (next) =>
      @_do options, next
    , callback
    return

  _do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?
    return callback @_userError(422, 'data.changeKey is required') unless data.changeKey?

    @bourse.forwardItem data, (error, results) =>
      return callback error if error?
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

module.exports = ForwardCalendarItem
