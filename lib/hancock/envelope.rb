module Hancock
  class Envelope
    #
    #for test connection
    #
    def build_uri(url)
      URI.parse("#{Hancock.endpoint}/#{Hancock.api_version}#{url}")
    end

    def get_login_information(options={})
      uri = build_uri('/login_information')
      headers = {
        'X-DocuSign-Authentication' => {
          'Username' => Hancock.username,
          'Password' => Hancock.password,
          'IntegratorKey' => Hancock.integrator_key
        }.to_json
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      response
    end
  end
end