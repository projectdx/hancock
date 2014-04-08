module Hancock
  class Base
    include Hancock::Validations
    include Hancock::Defaults
    include Hancock::Helpers
    extend Hancock::Helpers
      
    def [] attr
      if self.respond_to? attr
        self.send(attr)
      else
        raise NoMethodError.new(attr)
      end
    end
  end
end