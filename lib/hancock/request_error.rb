module Hancock
  class RequestError < StandardError
    def initialize(message, status=nil)
      @status = status
      super(message)
    end

    def docusign_status
      @status
    end
  end
end
