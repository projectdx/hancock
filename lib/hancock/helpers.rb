module Hancock
  module Helpers
    extend ActiveSupport::Concern

    def send_post_request(uri, body_post, headers)
      http = initialize_http(uri)

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body_post
      http.request(request) # return response
    end

    def send_get_request(uri, headers)
      http = initialize_http(uri)

      request = Net::HTTP::Get.new(uri.request_uri, headers)
      http.request(request) # return response
    end

    def get_response(url)
      uri = build_uri(url)
      content_headers = { 'Content-Type' => 'application/json' }

      send_get_request(uri, get_headers(content_headers))
    end

    def build_uri(url)
      URI.parse("#{Hancock.endpoint}/#{Hancock.api_version}#{url}")
    end

    def initialize_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    def get_headers(user_defined_headers={})
      default = {
        'Accept' => 'json',
        'X-DocuSign-Authentication' => {
          'Username' => Hancock.username,
          'Password' => Hancock.password,
          'IntegratorKey' => Hancock.integrator_key
        }.to_json 
      }

      default.merge!(user_defined_headers) if user_defined_headers
    end

    def get_recipients_for_request(signature_requests)
      recipients =  {
          signers: []
        }

      @signature_requests.each do |signature|
        p signature
        doc_signer = {
          email: signature[:recipient].email,
          name: signature[:recipient].name,
          recipientId:  signature[:recipient].identifier
        }

        doc_signer[:tabs] = {
          #here we can add more types
          initialHereTabs: get_tabs( signature[:tabs], "initial_here", signature[:document].identifier),
          signHereTabs:    get_tabs( signature[:tabs], "sign_here" , signature[:document].identifier),
        }

        recipients[:signers] << doc_signer
      end
      recipients
    end

    def get_content_type_for format, document={}
      case format
      when :json
        "Content-Type: application/json\r\n"\
        "Content-Disposition: form-data\r\n\r\n"
      when :pdf
        "Content-Type: application/pdf\r\n"\
        "Content-Disposition: file; filename=#{document.name}; documentid=#{document.identifier}\r\n\r\n"
      end
    end
  end
end