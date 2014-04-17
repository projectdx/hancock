module Hancock
  module Configuration

    include Hancock::Helpers

    VALID_CONNECTION_KEYS  = [:endpoint, :api_version, :user_agent, :method].freeze
    VALID_OPTIONS_KEYS     = [:access_token, :username, :password, :integrator_key, :account_id, :format, :ca_file, :email_template, :event_notification, :boundary].freeze

    VALID_CONFIG_KEYS      = VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

    DEFAULT_ENDPOINT       = 'https://demo.docusign.net/restapi'
    DEFAULT_API_VERSION    = 'v2'
    DEFAULT_USER_AGENT     = "DocusignRest API Ruby Gem #{Hancock::VERSION}".freeze
    DEFAULT_METHOD         = :get

    DEFAULT_ACCESS_TOKEN   = nil

    DEFAULT_BOUNDARY       = 'MYBOUNDARY'
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
      self.endpoint           = DEFAULT_ENDPOINT
      self.api_version        = DEFAULT_API_VERSION
      self.user_agent         = DEFAULT_USER_AGENT
      self.method             = DEFAULT_METHOD
      self.access_token       = DEFAULT_ACCESS_TOKEN
      self.username           = DEFAULT_USERNAME
      self.password           = DEFAULT_PASSWORD
      self.integrator_key     = DEFAULT_INTEGRATOR_KEY
      self.account_id         = DEFAULT_ACCOUNT_ID
      self.format             = DEFAULT_FORMAT
      self.ca_file            = DEFAULT_CA_FILE
      self.email_template     = DEFAULT_EMAIL_TEMPLATE
      self.event_notification = DEFAULT_EVENT_NOTIFICATION
      self.boundary           = DEFAULT_BOUNDARY
    end

    def configure
      yield self
      set_connect
    end

    #
    #  set up and configure a DocuSign Custom Connect definition for your account
    #
    def set_connect
      uri = build_uri("/accounts/#{Hancock.account_id}/connect")

      configurations = JSON.parse(send_get_request("/accounts/#{Hancock.account_id}/connect").body)["configurations"]
      connect_configuration = configurations.find{|k| k["name"] == Hancock.event_notification[:connect_name]}

      content_headers = { 'Content-Type' => 'application/json' }
      post_body = {
        allUsers: true,
        urlToPublishTo: Hancock.event_notification[:uri],
        enableLog: Hancock.event_notification[:logging_enabled],
        includeDocuments: Hancock.event_notification[:include_documents],
        useSoapInterface: "false",
        name: Hancock.event_notification[:connect_name],
        envelopeEvents: "Delivered, Sent, Completed",
        recipientEvents: "Delivered, Sent, Completed"
      }

      if connect_configuration
        post_body.merge!({connectId: connect_configuration["connectId"]}) 
        send_put_request(uri, post_body.to_json, get_headers(content_headers))
      else
        send_post_request(uri, post_body.to_json, get_headers(content_headers))
      end
    end

    def options
      Hash[ * VALID_CONFIG_KEYS.map { |key| [key, send(key)] }.flatten ]
    end
  end
end