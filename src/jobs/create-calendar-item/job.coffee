http        = require 'http'
_           = require 'lodash'
Bourse      = require 'bourse'

class CreateCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    # meshbluConfig = new MeshbluConfig({@auth}).toJSON()
    # meshbluHttp = new MeshbluHttp meshbluConfig

    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, username, password}

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?
    console.log('data', data)

    # options = {
    #   itemTimeZone: 'Pacific Standard Time'
    #   itemSendTo: 'SendToNone'
    #   itemSubject: 'Super Rad Meeting'
    #   itemBody: 'This meeting is like totally tubular'
    #   itemReminder: '2016-09-08T23:00:00-01:00'
    #   itemStart: '2016-09-09T00:29:00Z'
    #   itemEnd: '2016-09-09T01:00:00Z'
    #   itemLocation: 'Conf. Octoblu (Tempe)'
    # }

    @bourse.createItem data, (error, results) =>
      return callback @_userError(422, 'data is required') unless data?
      return callback @_userError(422, 'Subject is required') unless data.itemSubject?
      return callback @_userError(422, 'Body is required') unless data.itemBody?
      return callback @_userError(422, 'Start time is required') unless data.itemStart?
      return callback @_userError(422, 'End time is required') unless data.itemEnd?
      return callback @_userError(422, 'Attendees are required') unless data.itemAttendees?
      return callback @_userError(422, 'Location is required') unless data.itemLocation?
      console.log('data: ', data)
      console.log('create Item res: ', results)
      console.log('create Item res obj: ', results.Envelope.Body.CreateItemResponse)
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        # data: @_processResults results
        data: results
      }

  # _processResult: (result) =>
  #   {
  #     createdAt:   result.created_at
  #     description: result.payload.description
  #     type:        result.type
  #     username:    result.actor.display_login
  #   }
  #
  # _processResults: (results) =>
  #   _.map results, @_processResult

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = CreateCalendarItem
