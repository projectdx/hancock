class HancockController < ApplicationController
  #around_filter :global_request_logging

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

    #payload = File.open("callback.xml", "r")
    payload = request.raw_post
    @envelope_status = Hancock::EnvelopeStatus.new(payload)

    status = @envelope_status.status # here we got a status balue of a received evelope

    recipient_statuses = @envelope_status.recipient_statuses # fetch a collection of recipient statuses

    logger.debug 'Recipient id:'
    logger.debug recipient_statuses.first.recipient_id

    logger.debug 'Recipient status:'
    logger.debug recipient_statuses.first.status

    render :nothing => true

  end

end
