require 'hancock/version'
require 'hancock/exceptions'
require 'hancock/template_base'
require 'hancock/envelope'
require 'hancock/document'
require 'hancock/recipient'
require 'hancock/anchored_tab'
require 'hancock/tab'
require 'hancock/envelope_status'
require 'hancock/recepient_status'
require 'openssl'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'openssl'
require 'json'

require_relative 'hancock/configuration'

module Hancock
  extend Configuration
end
