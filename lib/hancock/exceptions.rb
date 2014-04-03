module Hancock
  # @abstact Exceptions raised by Gutenberg inherit from Error
  class Error < StandardError; end

  # Exception raised when Input file missing
  class ArgumentUnvalidError < Error
    def initialize arg, exspected
      message = "Unvalid argument. Exspected #{exspected}, got #{arg}"
      super(message)
    end
  end

  class NonadjacentArgumentError < Error; end
end