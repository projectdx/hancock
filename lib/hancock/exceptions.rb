module Hancock
  # @abstact Exceptions raised by Gutenberg inherit from Error
  class Error < StandardError; end

  # Exception raised when Input file missing
  class ArgumentUnvalidError < Error
    def initialize arg, expected
      message = "Invalid argument. Exspected #{expected}, got #{arg}"
      super(message)
    end
  end

  class NonadjacentArgumentError < Error; end
end