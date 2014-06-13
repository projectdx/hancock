require 'rubygems'
require 'bundler/setup'

require 'active_support/core_ext/string'
require 'active_support/inflector'

require 'hancock/helpers'
require_relative 'hancock/configuration'

require 'hancock/validations'

require 'nokogiri'
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
require 'hancock/callback'

module Hancock
  class ConfigurationMissing < StandardError; end

  extend Configuration

  def self.configured?
    oauth_token.present? && account_id.present?
  end
end
