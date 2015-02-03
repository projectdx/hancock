module Hancock
  class Base
    include ActiveModel::Validations
    include Hancock::Helpers
    extend Hancock::Helpers
  end
end
