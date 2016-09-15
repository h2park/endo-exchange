http        = require 'http'
_           = require 'lodash'
Bourse      = require 'bourse'

class GetCalendarItems
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, username, password}

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?

    @bourse.getIDandKey data, (error, results) =>
      return callback @_userError(422, 'data is required') unless data?
      ID = results.Envelope.Body.GetFolderResponse.ResponseMessages.GetFolderResponseMessage.Folders.CalendarFolder.FolderId.$.Id
      KEY = results.Envelope.Body.GetFolderResponse.ResponseMessages.GetFolderResponseMessage.Folders.CalendarFolder.FolderId.$.ChangeKey
      @bourse.getItems ID, KEY, (error, results) =>
        return callback error if error?

        processedResults = results.Envelope.Body.FindItemResponse.ResponseMessages.FindItemResponseMessage.RootFolder

        return callback null, {
          metadata:
            code: 200
            status: http.STATUS_CODES[200]
          data: processedResults
        }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = GetCalendarItems
