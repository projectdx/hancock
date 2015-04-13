require 'active_support/core_ext/string'
require 'active_support/inflector'
require 'active_support/concern'
require 'active_model'

require 'hancock/request'
require_relative 'hancock/configuration'

require 'nokogiri'
require 'json'

require 'hancock/base'
require 'hancock/docusign_adapter'
require 'hancock/version'
require 'hancock/envelope'
require 'hancock/document'
require 'hancock/recipient'
require 'hancock/anchored_tab'
require 'hancock/tab'

# Avoid deprecation warnings; ActiveSupport 4.1.0 loads i18n and displays a
# deprecation warning that while this variable currently defaults to false,
# it will default to true in the "future."
I18n.enforce_available_locales = true

module Hancock
  class ConfigurationMissing < StandardError; end

  extend Configuration

  def self.configured?
    oauth_token.present? && account_id.present?
  end
end
