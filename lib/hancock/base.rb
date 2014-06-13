module Hancock
  class Base
    include ActiveModel::Validations
    include Hancock::Helpers
    extend Hancock::Helpers

    private
      def generate_identifier
        Random.rand(1..1234)
      end
  end
end