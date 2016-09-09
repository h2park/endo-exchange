http        = require 'http'
_           = require 'lodash'
Bourse      = require 'bourse'

Exchange = require '../../services/exchange-service'

class CreateCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    # meshbluConfig = new MeshbluConfig({@auth}).toJSON()
    # meshbluHttp = new MeshbluHttp meshbluConfig

    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @exchange = new Exchange {hostname, domain, username, password}
    @bourse = new Bourse {hostname, username, password}

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?
    console.log('data', data)

    options = {
      itemTimeZone: 'Pacific Standard Time'
      itemSendTo: 'SendToNone'
      itemSubject: 'Super Rad Meeting'
      itemBody: 'This meeting is like totally tubular'
      itemReminder: '2016-09-08T23:00:00-01:00'
      itemStart: '2016-09-09T00:29:00Z'
      itemEnd: '2016-09-09T01:00:00Z'
      itemLocation: 'Conf. Octoblu (Tempe)'
    }

    @bourse.createItem options, (error, response) =>
      return callback error if error?
      console.log('Response: ', response.Envelope.Body.CreateItemResponse)

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

module.exports = CreateCalendarItem
