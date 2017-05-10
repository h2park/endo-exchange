http        = require 'http'
Bourse      = require 'bourse'
_           = require 'lodash'
async       = require 'async'

class DeleteCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, username, password}

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

  _do: ({data}, callback) =>
    return callback @_userError(422, 'data is required.') unless data?

    @bourse.deleteItem data, (error, results) =>
      return callback error if error?
      return callback null, {
        metadata:
          code: 204
          status: http.STATUS_CODES[204]
      }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = DeleteCalendarItem
