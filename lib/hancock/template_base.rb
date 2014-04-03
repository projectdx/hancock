module Hancock
  class TemplateBase

    def [] attr
      if self.respond_to? attr
        self.send(attr)
      else
        raise NoMethodError.new(attr)
      end
    end

    private
      def generate_identifier
        Random.rand(1234)
      end
  end
end