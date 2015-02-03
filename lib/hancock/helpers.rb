require 'httparty'

module Hancock
  module Helpers
    def send_request(type, url, headers, body = nil)
      uri = build_uri(url)
      options = { :headers => headers }
      options[:body] = body if body
      HTTParty.send(type, uri, options)
    end
    #
    # send post request to set uri with post body and headers
    #
    def send_post_request(url, body_post, headers)
      send_request(:post, url, headers, body_post)
    end

    #
    # send put request to set url
    #
    def send_put_request(url, body_post, headers)
      send_request(:put, url, headers, body_post)
    end

    #
    # send get request to set url
    #
    def send_get_request(url)
      send_request(:get, url, get_headers('Content-Type' => 'application/json'))
    end

    #
    # generate common uri to docusign service
    #
    def build_uri(url)
      "#{Hancock.endpoint}/#{Hancock.api_version}#{url}"
    end

    #
    # get headers for requests with authentication parameters
    #
    def get_headers(user_defined_headers = {})
      default = {
        'Accept' => 'json',
        'Authorization' => "bearer #{Hancock.oauth_token}"
      }

      default.merge!(user_defined_headers) if user_defined_headers
    end

    #
    # format recipient type(symbol) for DocuSign
    #
    def docusign_recipient_type(type)
      type.to_s.camelize(:lower).pluralize
    end
  end
end
