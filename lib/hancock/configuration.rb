module Hancock
  module Configuration
    VALID_CONNECTION_KEYS  = [:endpoint, :api_version, :user_agent, :method].freeze
    VALID_OPTIONS_KEYS     = [
      :oauth_token,
      :account_id,
      :format,
      :ca_file,
      :email_template,
      :event_notification,
      :boundary,
      :logger,
      :placeholder_email
    ].freeze

    VALID_CONFIG_KEYS      = VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

    DEFAULT_ENDPOINT       = 'https://demo.docusign.net/restapi'
    DEFAULT_API_VERSION    = 'v2'
    DEFAULT_METHOD         = :get

    DEFAULT_BOUNDARY       = 'MYBOUNDARY'
    DEFAULT_OAUTH_TOKEN    = nil
    DEFAULT_ACCOUNT_ID     = nil
    DEFAULT_CA_FILE        = nil
    DEFAULT_FORMAT         = :json
    DEFAULT_EMAIL_TEMPLATE = {}
    DEFAULT_LOGGER         = Logger.new($stdout)
    DEFAULT_EVENT_NOTIFICATION = {
      :logging_enabled => false,
      :uri => 'http://domain.com/hancock/process_callback',
      :include_documents => false
    }

    DEFAULT_PLACEHOLDER_EMAIL = 'placeholder@example.com'

    attr_accessor *VALID_CONFIG_KEYS

    def self.extended(base)
      base.reset
    end

    def reset
      self.endpoint           = DEFAULT_ENDPOINT
      self.api_version        = DEFAULT_API_VERSION
      self.method             = DEFAULT_METHOD
      self.oauth_token        = DEFAULT_OAUTH_TOKEN
      self.account_id         = DEFAULT_ACCOUNT_ID
      self.format             = DEFAULT_FORMAT
      self.ca_file            = DEFAULT_CA_FILE
      self.email_template     = DEFAULT_EMAIL_TEMPLATE
      self.event_notification = DEFAULT_EVENT_NOTIFICATION
      self.boundary           = DEFAULT_BOUNDARY
      self.placeholder_email  = DEFAULT_PLACEHOLDER_EMAIL
      self.logger             = DEFAULT_LOGGER
    end

    def configure
      yield self
    end
  end
end
