require "hancock/version"

require_relative 'hancock/configuration'

module Hancock
  extend Configuration
	class Envelope 
	  

		#
		#for test connection
		#
	  def build_uri(url)
	    URI("#{Hancock.endpoint}/#{Hancock.api_version}#{url}")
	  end

	  def get_login_information(options={})
	    uri = build_uri('/login_information')
	    request = Net::HTTP.get(uri)
	    # p request
	  end
	end
end
