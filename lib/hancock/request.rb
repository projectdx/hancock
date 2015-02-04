require 'httparty'

module Hancock
  class Request
    RequestError = Class.new(StandardError)

    def self.send_request(type, url, headers, body = nil)
      uri = build_uri(url)
      options = { :headers => headers }
      options[:body] = body if body
      response = HTTParty.send(type, uri, options)

      unless response.success?
        parsed_response = JSON.parse(response.body)
        fail RequestError, "#{response.response.code} - #{parsed_response['errorCode']} - #{parsed_response['message']}"
      end

      response
    end

    #
    # send post request to set uri with post body and headers
    #
    def self.send_post_request(url, body_post, headers)
      send_request(:post, url, headers, body_post)
    end

    #
    # send put request to set url
    #
    def self.send_put_request(url, body_post, headers)
      send_request(:put, url, headers, body_post)
    end

    #
    # send get request to set url
    #
    def self.send_get_request(url)
      send_request(:get, url, get_headers('Content-Type' => 'application/json'))
    end

    #
    # send delete request to set url
    #
    def self.send_delete_request(url, body_post)
      send_request(:delete, url, get_headers('Content-Type' => 'application/json'), body_post)
    end

    #
    # generate common uri to docusign service
    #
    def self.build_uri(url)
      "#{Hancock.endpoint}/#{Hancock.api_version}/accounts/#{Hancock.account_id}#{url}"
    end

    #
    # get headers for requests with authentication parameters
    #
    def self.get_headers(user_defined_headers = {})
      default = {
        'Accept' => 'json',
        'Authorization' => "bearer #{Hancock.oauth_token}"
      }

      default.merge!(user_defined_headers) if user_defined_headers
    end
  end
end
