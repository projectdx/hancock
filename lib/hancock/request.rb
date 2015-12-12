require 'httparty'

module Hancock
  class Request
    RequestError = Class.new(StandardError)

    attr_reader :uri, :type, :headers, :body, :response

    class << self
      def send_post_request(url, body, custom_headers = {})
        new(
          :type => :post,
          :url => url,
          :custom_headers => custom_headers,
          :body => body
        ).send_request
      end

      def send_put_request(url, body, custom_headers = {})
        new(
          :type => :put,
          :url => url,
          :custom_headers => custom_headers,
          :body => body
        ).send_request
      end

      def send_get_request(url)
        new(
          :type => :get,
          :url => url
        ).send_request
      end

      def send_delete_request(url, body, custom_headers = {})
        new(
          :type => :delete,
          :url => url,
          :custom_headers => custom_headers,
          :body => body
        ).send_request
      end
    end

    def initialize(type:, url:, custom_headers: {}, body: nil)
      @type = type
      @uri = build_uri(url)
      @headers = default_headers.merge(custom_headers)
      @body = body
    end

    def send_request
      @response = HTTParty.send(type, uri, options)

      Hancock.logger.info("#{type.upcase}: #{uri}\n#{options}")

      unless success?
        Hancock.logger.error("#{response.response.code}:\n#{response}")
        fail RequestError, "#{response.response.code} - #{response}"
      end

      Hancock.logger.debug("#{response.response.code}: #{response}")

      response
    end

    private

    def default_headers
      {
        'Accept' => 'application/json',
        'Authorization' => "bearer #{Hancock.oauth_token}",
        'Content-Type' => 'application/json'
      }
    end

    def options
      {
        :headers => headers,
        :body => body
      }
    end

    def build_uri(url)
      "#{Hancock.endpoint}/#{Hancock.api_version}/accounts/#{Hancock.account_id}#{url}"
    end

    def success?
      response.success? && !has_error?
    end

    def has_error?
      if response.content_type == "application/json"
        includes_error_code?(JSON.parse(response.body))
      end
    end

    def includes_error_code?(data)
      case data
      when Hash
        if data.has_key?("errorCode") && data["errorCode"] != "SUCCESS"
          true
        else
          data.values.any? { |element| includes_error_code?(element) }
        end
      when Array
        data.any?{ |element| includes_error_code?(element) }
      else
        false
      end
    end
  end
end
