require 'httparty'

module Hancock
  class Request
    RequestError = Class.new(StandardError)

    def self.send_request(type, url, headers, body = nil)
      uri = build_uri(url)
      options = { :headers => headers }
      options[:body] = body if body
      response = HTTParty.send(type, uri, options)

      Hancock.logger.info("#{type.upcase}: #{uri}\n#{options}")

      if !response.success? || response["errorCode"].present?
        Hancock.logger.error("#{response.response.code}:\n#{response}")
        fail RequestError, "#{response.response.code} - #{response['errorCode']} - #{response['message']}"
      end

      Hancock.logger.debug("#{response.response.code}: #{response}")

      response
    end

    #
    # send post request to set uri with post body and headers
    #
    def self.send_post_request(url, body_post, headers = {})
      send_request(:post, url, merge_headers(headers), body_post)
    end

    #
    # send put request to set url
    #
    def self.send_put_request(url, body_post, headers = {})
      send_request(:put, url, merge_headers(headers), body_post)
    end

    #
    # send get request to set url
    #
    def self.send_get_request(url)
      send_request(:get, url, merge_headers)
    end

    #
    # send delete request to set url
    #
    def self.send_delete_request(url, body_post, headers = {})
      send_request(:delete, url, merge_headers(headers), body_post)
    end

    #
    # generate common uri to docusign service
    #
    def self.build_uri(url)
      "#{Hancock.endpoint}/#{Hancock.api_version}/accounts/#{Hancock.account_id}#{url}"
    end

    #
    # Merge default headers with these headers
    #
    def self.merge_headers(user_defined_headers = {})
      default_headers = {
        'Accept' => 'application/json',
        'Authorization' => "bearer #{Hancock.oauth_token}",
        'Content-Type' => 'application/json'
      }

      user_defined_headers.each do |key, value|
        default_headers[key] = value
      end

      default_headers
    end
  end
end
