require 'trello'
require 'rainbow'
require 'set'
require 'yaml'
require 'chronic'
require 'mongoid'
require 'forwardable'

require 'tracco/cli'
require 'tracco/version'
require 'tracco/mongoid_helper'
require 'tracco/trello_configuration'
require 'tracco/trello_authorize'
require 'tracco/models/tracked_card'
require 'tracco/models/member'
require 'tracco/models/estimate'
require 'tracco/models/effort'
require 'tracco/tracking/base'
require 'tracco/tracking/estimate_tracking'
require 'tracco/tracking/effort_tracking'
require 'tracco/tracking/card_done_tracking'
require 'tracco/tracking/invalid_tracking'
require 'tracco/tracking/factory'
require 'tracco/trello_tracker'
require 'tracco/configuration'
require 'tracco/exporters/google_docs'

require 'patches/trello/member'
require 'patches/trello/card'

Trello.logger.level = Logger::INFO
Tracco.load_env!
