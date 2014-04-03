module Hancock
  module Helpers
    extend ActiveSupport::Concern

    def post_request(uri, body_post, headers)
      http = initialize_http(uri)

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body_post
      http.request(request) # return response
    end

    def get_request(uri, headers)
      http = initialize_http(uri)

      request = Net::HTTP::Get.new(uri.request_uri, headers)
      http.request(request) # return response
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
    end
  end
end