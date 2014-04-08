module Hancock
  module Configuration
    VALID_CONNECTION_KEYS  = [:endpoint, :api_version, :user_agent, :method].freeze
    VALID_OPTIONS_KEYS     = [:access_token, :username, :password, :integrator_key, :account_id, :format, :ca_file, :email_template].freeze
    VALID_CONFIG_KEYS      = VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

    DEFAULT_ENDPOINT       = 'https://demo.docusign.net/restapi'
    DEFAULT_API_VERSION    = 'v2'
    DEFAULT_USER_AGENT     = "DocusignRest API Ruby Gem #{Hancock::VERSION}".freeze
    DEFAULT_METHOD         = :get

    DEFAULT_ACCESS_TOKEN   = nil

    DEFAULT_USERNAME       = nil
    DEFAULT_PASSWORD       = nil
    DEFAULT_INTEGRATOR_KEY = nil
    DEFAULT_ACCOUNT_ID     = nil
    DEFAULT_CA_FILE        = nil 
    DEFAULT_FORMAT         = :json
    DEFAULT_EMAIL_TEMPLATE = nil
    DEFAULT_EVENT_NOTIFICATION = {
        :logging_enabled => false,
        :uri => 'http://domain.com/hancock/process_callback',
        :include_documents => false,
    }

    attr_accessor *VALID_CONFIG_KEYS

    def self.extended(base)
      base.reset
    end

    def reset
      self.endpoint       = DEFAULT_ENDPOINT
      self.api_version    = DEFAULT_API_VERSION
      self.user_agent     = DEFAULT_USER_AGENT
      self.method         = DEFAULT_METHOD
      self.access_token   = DEFAULT_ACCESS_TOKEN
      self.username       = DEFAULT_USERNAME
      self.password       = DEFAULT_PASSWORD
      self.integrator_key = DEFAULT_INTEGRATOR_KEY
      self.account_id     = DEFAULT_ACCOUNT_ID
      self.format         = DEFAULT_FORMAT
      self.ca_file        = DEFAULT_CA_FILE
      self.email_template = DEFAULT_EMAIL_TEMPLATE
      self.event_notification = DEFAULT_EVENT_NOTIFICATION
    end

    def configure
      yield self
    end

    def options
      Hash[ * VALID_CONFIG_KEYS.map { |key| [key, send(key)] }.flatten ]
    end
  end
end