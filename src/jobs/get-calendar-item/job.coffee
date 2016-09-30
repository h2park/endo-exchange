Bourse      = require 'bourse'
http        = require 'http'
_           = require 'lodash'

class GetCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, username, password}

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?

    {itemId} = data
    # itemId = 'Boo'
    # ID = results.Envelope.Body.GetFolderResponse.ResponseMessages.GetFolderResponseMessage.Folders.CalendarFolder.FolderId.$.Id

    @bourse.getItemByItemId data.itemId, (error, response) =>
      console.log "@bourse.getItemByItemId: #{data.itemId}"


      return callback error if error?
      console.log "Response", JSON.stringify response, null, 2
      {CalendarItem} = response.Envelope.Body.GetItemResponse.ResponseMessages.GetItemResponseMessage.Items
      {Id, ChangeKey} = CalendarItem.ItemId.$
      processedResponse =
        itemId: Id
        changeKey: ChangeKey
        start: CalendarItem.Start
        subject: CalendarItem.Subject
        end: CalendarItem.End
        organizer:
          name: CalendarItem.Organizer?.Mailbox?.Name
          email: CalendarItem.Organizer?.Mailbox?.EmailAddress
        location: CalendarItem.Location
        timezone: CalendarItem.TimeZone

      console.log "@bourse.getItemByItemId response:", JSON.stringify(processedResponse)

      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: processedResponse
      }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = GetCalendarItem
