require_relative 'hancock/configuration'

require 'hancock/helpers'

require 'openssl'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'openssl'
require 'json'

require 'hancock/base'
require 'hancock/version'
require 'hancock/exceptions'
require 'hancock/envelope'
require 'hancock/document'
require 'hancock/recipient'
require 'hancock/anchored_tab'
require 'hancock/tab'
require 'hancock/envelope_status'
require 'hancock/recepient_status'

module Hancock
  extend Configuration
end
