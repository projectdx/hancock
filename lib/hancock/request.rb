require 'faraday'
require 'faraday_middleware'

module Hancock
  class Request
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
      @response = connection.send(type) do |req|
        req.url(uri)
        req.headers = headers
        req.body = body if body
        req.options.timeout = Hancock.request_timeout
      end

      Hancock.logger.info("#{type.upcase}: #{uri}\n{headers:#{headers}}")

      unless success?
        Hancock.logger.error("#{response_status}:\n#{parsed_response}")
        fail RequestError.new(message, error_code)
      end

      Hancock.logger.debug("#{response_status}: #{parsed_response}")

      parsed_response || response_body
    end

    private

    def connection
      Faraday.new do |builder|
        builder.use FaradayMiddleware::FollowRedirects, limit: 5
        builder.response :logger, Hancock.logger
        builder.adapter Faraday.default_adapter
      end
    end

    def default_headers
      {
        'Accept' => 'application/json',
        'Authorization' => "bearer #{Hancock.oauth_token}",
        'Content-Type' => 'application/json',
        'X-DocuSign-TimeTrack' => 'DS-REQUEST-TIME'
      }
    end

    def build_uri(url)
      "#{Hancock.endpoint}/#{Hancock.api_version}/accounts/#{Hancock.account_id}#{url}"
    end

    def success?
      response.success? && !has_error?
    end

    def has_error?
      error_code && error_code != 'SUCCESS'
    end

    def parsed_response
      if /application\/json/.match(response_headers["content-type"])
        JSON.parse(response_body)
      end
    end

    def response_content_type
      response_headers["content_type"]
    end

    def response_status
      response.env.status
    end

    def response_headers
      response.env.response_headers
    end

    def response_body
      response.env.body
    end

    def error_code
      deep_find_by_key(parsed_response, "errorCode")
    end

    def message
      deep_find_by_key(parsed_response, "message")
    end

    def deep_find_by_key(data, key)
      case data
      when Hash
        data[key] || iteratively_find_by_key(data.values, key)
      when Array
        iteratively_find_by_key(data, key)
      end
    end

    def iteratively_find_by_key(data, key)
      data.find{ |item| deep_find_by_key(item, key) }
    end
  end
end
