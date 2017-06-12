_           = require 'lodash'
URL         = require 'url'
http        = require 'http'
Bourse      = require 'bourse'
async       = require 'async'

class GetCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname} = encrypted.secrets
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
    return callback @_userError(422, 'data.itemId is required.') unless data.itemId?

    @bourse.getItemByItemId data.itemId, (error, response) =>
      return callback error if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: @_addJoinOnlineMeetingUrl response
      }

  _addJoinOnlineMeetingUrl: (meeting) =>
    return meeting unless _.isEmpty meeting.joinOnlineMeetingUrl
    skypeUrls = _.filter meeting.urls, ({url, hostname}={}) =>
      return true if hostname == "meet.lync.com"
      {path} = URL.parse url
      return path.match /^\/.*\/[A-Z0-9]{8}$/

    meeting.joinOnlineMeetingUrl = _.first skypeUrls
    return meeting

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = GetCalendarItem
