require "hancock/version"

require_relative 'hancock/configuration'

module Hancock
  extend Configuration
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

	    request = Net::HTTP::Get.new(uri.request_uri, headers)
	   	http = Net::HTTP.new(uri.host)		
			response = http.request(request)

	    response
	    
	  end
	end
end
