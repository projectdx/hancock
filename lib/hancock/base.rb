module Hancock
  class Base
    include Hancock::Validations
    include Hancock::Helpers
    extend Hancock::Helpers
      
    def [] attr
      if self.respond_to? attr
        self.send(attr)
      else
        raise NoMethodError.new(attr)
      end
    end

    def generate_identifier
      Random.rand(1..1234)
    end
  end
end