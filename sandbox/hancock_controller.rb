class HancockController < ApplicationController
  around_filter :global_request_logging

  require 'hancock'
  require 'nokogiri'
  require 'active_support/core_ext/hash/conversions'


  def global_request_logging
    http_request_header_keys = request.headers.env.select{|header_name| header_name.match("^HTTP.*")}
    http_request_headers = request.headers.env.select{|header_name, header_value| http_request_header_keys.include?(header_name)}
    logger.info "Received #{request.method.inspect} to #{request.url.inspect} from #{request.remote_ip.inspect}.  Processing with headers #{http_request_headers.inspect} and params #{params.inspect}"
    begin
      yield
    ensure
      logger.info "Responding with #{response.status.inspect} => #{response.body.inspect}"
      logger.debug response.body
    end
  end


  def process_callback

    if params.keys.first.include? 'xml'

      payload = params.keys.first + params.values.first
      @envelope_status = Hancock::EnvelopeStatus.new(payload)

      logger.debug 'Got Envelope Status:'
      logger.debug @envelope_status.status

    else
      logger.debug 'No XML payload found. Skipping...'
    end

    # @recepient_status = Hancock::RecepientStatus.new(response.body)

    render :nothing => true

  end

end
