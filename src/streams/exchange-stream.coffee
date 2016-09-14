_ = require 'lodash'
Bourse = require 'bourse'
stream = require 'stream'
xmlNodes = require 'xml-nodes'
xmlObjects = require 'xml-objects'
xml2js = require 'xml2js'

debug = require('debug')('slurry-exchange:exchange-stream')

XML_OPTIONS = {
  tagNameProcessors: [xml2js.processors.stripPrefix]
  explicitArray: false
}

MEETING_RESPONSE_PATH = 'Envelope.Body.GetItemResponse.ResponseMessages.GetItemResponseMessage.Items'

class ExchangeStream extends stream.Readable
  constructor: ({connectionOptions, @request}) ->
    super objectMode: true

    {protocol, hostname, port, username, password} = connectionOptions
    @bourse = new bourse {protocol, hostname, port, username, password}

    console.log 'connecting...'
    tee = @request
      .pipe(xmlNodes('Envelope'))
    tee
      .pipe(xmlObjects(XML_OPTIONS))
      .on 'data', boarse._onData

    # tee.on 'data', (data) => console.log data.toString()

  destroy: =>
    return @request.abort() if _.isFunction @request.abort
    @request.socket.destroy()
    @push null


module.exports = ExchangeStream
