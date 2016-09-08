http   = require 'http'
_      = require 'lodash'

Exchange = require '../../services/exchange-service'

class GetCalendarEvents
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    meshbluConfig = new MeshbluConfig({@auth}).toJSON()
    meshbluHttp = new MeshbluHttp meshbluConfig

    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @exchange = new Exchange {hostname, domain, username, password}

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?
    console.log('data', data)

    @github.activity.getEventsForUser {user: data.username}, (error, results) =>
      return callback error if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: @_processResults results
      }

  _processResult: (result) =>
    {
      createdAt:   result.created_at
      description: result.payload.description
      type:        result.type
      username:    result.actor.display_login
    }

  _processResults: (results) =>
    _.map results, @_processResult

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = GetCalendarEvents
