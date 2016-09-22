_ = require 'lodash'
Bourse = require 'bourse'

SUBSCRIPTION_ID_PATH = 'Envelope.Body.SubscribeResponse.ResponseMessages.SubscribeResponseMessage.SubscriptionId'

class Exchange
  constructor: ({protocol, hostname, port, @username, @password}) ->
    throw new Error 'Missing required parameter: hostname' unless hostname?
    throw new Error 'Missing required parameter: username' unless @username?
    throw new Error 'Missing required parameter: password' unless @password?

    protocol ?= 'https'
    port ?= 443

    @connectionOptions = {protocol, hostname, port, @username, @password}
    @bourse = new Bourse @connectionOptions

  getCalendar: ({distinguishedFolderId}, callback) =>
    @bourse.getCalendar {distinguishedFolderId}, (error, response) =>
      return callback error if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: response
        }

module.exports = Exchange
