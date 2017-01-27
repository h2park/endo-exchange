http    = require 'http'
Bourse  = require 'bourse'
Redis   = require 'ioredis'
Redlock = require 'redlock'
_       = require 'lodash'

cachedRedlockClient  = null

class CreateCalendarItem
  constructor: ({encrypted, @auth, @userDeviceUuid}) ->
    {hostname, domain} = encrypted.secrets
    {username, password} = encrypted.secrets.credentials

    @bourse = new Bourse {hostname, domain, username, password}
    @redisUri ?= process.env.REDIS_URI

  getRedlockClient: (callback) =>
    return callback null, cachedRedlockClient if cachedRedlockClient?
    callback = _.once callback
    client = new Redis @redisUri, dropBufferSupport: true
    client.ping (error) =>
      return callback error if error?
      cachedRedlockClient = new Redlock [client], retryCount: 150, retryDelay: 200
      callback null, cachedRedlockClient

  createLock: ({ key, callback, timeout=30000 }, done) =>
    @getRedlockClient (error, redlock) =>
      return done error if error?
      redlock.lock key, timeout, (error, lock) =>
        return done error if error?
        unlockCallback = (error, response) =>
          lock.unlock (lockError) =>
            console.error lockError if lockError?
            callback error, response
        done null, unlockCallback

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?
    searchableId = _.get data, 'extendedProperties.genisysSearchableId'

    key = "endo:exchange:create-calendar-item:#{searchableId}"
    @createLock { key, callback }, (error, unlockCallback) =>
      return callback error if error?
      extendedProperties = {
        genisysMeetingId: true
        genisysSearchableId: true
      }

      @bourse.findItemsByExtendedProperty { Id: 'calendar', key: 'genisys-searchable-id', value: searchableId, extendedProperties }, (error, items) =>
        return unlockCallback error if error?

        if _.isEmpty items
          return @bourse.createItem data, (error, results) =>
            return unlockCallback error if error?
            return unlockCallback null, {
              metadata:
                code: 201
                status: http.STATUS_CODES[201]
              data: results
            }

        unlockCallback null, {
          metadata:
            code: 409
            status: http.STATUS_CODES[409]
        }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = CreateCalendarItem
