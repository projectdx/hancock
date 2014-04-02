module Hancock
  class Envelope
    
    def initialize
      @post_body = {
        documents: {}, 
        recipients: {}
      }

      @docusign_headers = {
        'X-DocuSign-Authentication' => {
          'Username' => Hancock.username,
          'Password' => Hancock.password,
          'IntegratorKey' => Hancock.integrator_key
        }.to_json
      }
    end

    def add_document doc 
      # @post_body.merge!({
      #     documents: {
      #       documentId: doc.identifier,
      #       name: doc.name
      #     }
      #   }
      # )
    end

    def add_signature_request doc 
      # @post_body.merge!({
      #     recipients: {
      #       signers: get_signers(options[:signers])
      #     },
      #     tabs: {

      #     }
      #   }
      # )
    end

    def send!
      @post_body.merge!({
          emailBlurb:   "emailBlurb",
          emailSubject: "emailSubject",
          status: "sent"
        }
      )

      uri = build_uri("/accounts/#{Hancock.account_id}/envelopes")
      http = initialize_http(uri)

      headers = {
        'Content-Type'              => "multipart/form-data",
        'Accept'                    => 'application/json',
        'Content-Length'            => "#{@post_body.length}"
      }
      headers.merge!(@docusign_headers)

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = post_body
      response = http.request(request)
      response.body
    end

    def build_uri(url)
      URI.parse("#{Hancock.endpoint}/#{Hancock.api_version}#{url}")
    end

    #
    #for testing connection
    #
    def get_login_information(options={})
      uri = build_uri('/login_information')
      
      http = initialize_http(uri)

      request = Net::HTTP::Get.new(uri.request_uri, @docusign_headers)
      response = http.request(request)
      response
    end

    def initialize_http uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end
  end
end