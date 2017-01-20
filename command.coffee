_               = require 'lodash'
MeshbluConfig   = require 'meshblu-config'
path            = require 'path'
Endo            = require 'endo-core'
OctobluStrategy = require 'endo-core/octoblu-strategy'
MessageHandler  = require 'endo-core/message-handler'
SigtermHandler  = require 'sigterm-handler'
ApiStrategy     = require './src/api-strategy'

MISSING_SERVICE_URL = 'Missing required environment variable: ENDO_EXCHANGE_SERVICE_URL'
MISSING_MANAGER_URL = 'Missing required environment variable: ENDO_EXCHANGE_MANAGER_URL'
MISSING_APP_OCTOBLU_HOST = 'Missing required environment variable: APP_OCTOBLU_HOST'
MISSING_ENDO_EXCHANGE_STATIC_SCHEMAS_PATH = 'Missing required environment variable: ENDO_EXCHANGE_STATIC_SCHEMAS_PATH'
MISSING_REDIS_URI = 'Missing required environment variable: REDIS_URI'

class Command
  getOptions: =>
    throw new Error MISSING_SERVICE_URL if _.isEmpty process.env.ENDO_EXCHANGE_SERVICE_URL
    throw new Error MISSING_MANAGER_URL if _.isEmpty process.env.ENDO_EXCHANGE_MANAGER_URL
    throw new Error MISSING_APP_OCTOBLU_HOST if _.isEmpty process.env.APP_OCTOBLU_HOST
    throw new Error MISSING_ENDO_EXCHANGE_STATIC_SCHEMAS_PATH if _.isEmpty process.env.ENDO_EXCHANGE_STATIC_SCHEMAS_PATH
    throw new Error MISSING_REDIS_URI if _.isEmpty process.env.REDIS_URI

    meshbluConfig   = new MeshbluConfig().toJSON()
    apiStrategy     = new ApiStrategy process.env
    octobluStrategy = new OctobluStrategy process.env, meshbluConfig

    jobsPath = path.join __dirname, 'src/jobs'

    return {
      apiStrategy:     apiStrategy
      deviceType:      'endo:exchange'
      disableLogging:  process.env.DISABLE_LOGGING == "true"
      meshbluConfig:   meshbluConfig
      messageHandler:  new MessageHandler {jobsPath}
      octobluStrategy: octobluStrategy
      port:            process.env.PORT || 80
      appOctobluHost:  process.env.APP_OCTOBLU_HOST
      serviceUrl:      process.env.ENDO_EXCHANGE_SERVICE_URL
      userDeviceManagerUrl: process.env.ENDO_EXCHANGE_MANAGER_URL
      staticSchemasPath: process.env.ENDO_EXCHANGE_STATIC_SCHEMAS_PATH
      useFirehose: process.env.ENDO_EXCHANGE_USE_FIREHOSE
      skipExpress: process.env.ENDO_EXCHANGE_SKIP_EXPRESS
      redisUri: process.env.REDIS_URI
      skipRedirectAfterApiAuth: true
    }

  run: =>
    options = @getOptions()
    server = new Endo options
    server.run (error) =>
      throw error if error?
      unless options.skipExpress
        {address,port} = server.address()
        console.log "Server listening on #{address}:#{port}"

    sigtermHandler = new SigtermHandler
    sigtermHandler.register server.stop

command = new Command()
command.run()
