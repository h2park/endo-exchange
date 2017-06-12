http        = require 'http'
Bourse      = require 'bourse'
_           = require 'lodash'
URL         = require 'url'
async       = require 'async'

class GetCalendarItemsInRange
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

  _do: ({data}, callback) =>
    return callback @_userError(422, 'Missing required parameter: data.start') unless _.has data, 'start'
    return callback @_userError(422, 'Missing required parameter: data.end') unless _.has data, 'end'

    {start, end} = data
    extendedProperties =
      'genisysMeetingId': true
      'genisysSearchableId': true

    @bourse.getCalendarItemsInRange {start, end, extendedProperties}, (error, items) =>
      return callback error if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: _.map items, @_addJoinOnlineMeetingUrl
      }

  _addJoinOnlineMeetingUrl: (meeting) =>
    return meeting unless _.isEmpty meeting.joinOnlineMeetingUrl
    skypeUrls = _.filter meeting.urls, ({url, hostname}={}) =>
      return true if hostname == "meet.lync.com"
      {path} = URL.parse url
      return path.match /^\/.*\/[A-Z0-9]{8}$/

    skypeUrls = _.map skypeUrls, 'url'
    meeting.joinOnlineMeetingUrl = _.first skypeUrls
    return meeting

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = GetCalendarItemsInRange
