module Hancock
  # @abstact Exceptions raised by Gutenberg inherit from Error
  class Error < StandardError; end

  class ArgumentError < Error; end

  # @abstact Exceptions raised by Gutenberg inherit from Error
  class DocusignError < Error; end
end