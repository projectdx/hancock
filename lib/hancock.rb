require 'hancock/helpers'
require_relative 'hancock/configuration'

unless defined?(Rails)
  require 'active_support/concern'
  require 'active_support/inflector'
end

require 'hancock/validations'

require 'openssl'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'openssl'
require 'json'

require 'hancock/base'
require 'hancock/docusign_adapter'
require 'hancock/version'
require 'hancock/exceptions'
require 'hancock/envelope'
require 'hancock/document'
require 'hancock/recipient'
require 'hancock/anchored_tab'
require 'hancock/tab'
require 'hancock/envelope_status'
require 'hancock/recipient_status'

module Hancock
  extend Configuration
end
