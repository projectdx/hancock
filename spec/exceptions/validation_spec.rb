require_relative '../spec_helper'

describe Hancock::Validations do

  describe 'Method "unless"' do
    class Foo
      include Hancock::Validations
      attr_accessor :bar, :babar

      validates :bar, presence: true, unless: :babar
    end

    it 'should raise an error if validation-arrt and unless-condition attr is blank' do
      class Foo
        def initialize(args={})
          self.validate!
        end
      end
      expect { Foo.new() }.to raise_error()
    end

    it 'skips validations if condition attr isnt blank' do 
      class Foo
        def initialize(args={})
          @babar = args[:babar]
          self.validate!
        end
      end
      expect { Foo.new({babar: :babar}) }.to_not raise_error()
    end
  end

  describe 'Method "if"' do
    class Bar
      include Hancock::Validations
      attr_accessor :bar, :babar

      validates :bar, presence: true, if: :babar
    end

    it 'should raise an error if validation-arrt is blank' do
      class Bar
        def initialize(args={})
          @babar = args[:babar]
          self.validate!
        end
      end
      expect { Bar.new({babar: :babar}) }.to raise_error()
    end

    it 'skips validations if condition attr is blank' do 
      class Bar
        def initialize(args={})
          self.validate!
        end
      end
      expect { Bar.new() }.to_not raise_error()
    end
  end


  describe 'Method "allow_nil"' do
    class FooBar
      include Hancock::Validations
      attr_accessor :bar, :babar

      validates :bar, type: :file, allow_nil: true
    end

    it 'skips validations if validation-arrt is nil' do
      class FooBar
        def initialize(args={})
          @babar = args[:babar]
          self.validate!
        end
      end
      expect { FooBar.new({babar: :babar}) }.to_not raise_error()
    end

    it 'run validations if validation-arrt isnt nil' do 
      class FooBar
        def initialize(args={})
          @bar = args[:bar]
          self.validate!
        end
      end
      expect { FooBar.new({bar: 'string'}) }.to raise_error()
    end
  end
    
  describe 'Methos "presence"' do
    class BarFoo
      include Hancock::Validations
      attr_accessor :bar, :babar

      validates :bar, presence: true
    end

    it 'raises and error if validation-arrt is nil' do 
      class BarFoo
        def initialize(args={})
          self.validate!
        end
      end
      expect { BarFoo.new() }.to raise_error()
    end

    it 'Dont raises and error if validation-arrt isnt nil' do 
      class BarFoo
        def initialize(args={})
          @bar = args[:bar]
          self.validate!
        end
      end
      expect { BarFoo.new({bar: :bar}) }.to_not raise_error()
    end
  end


  describe 'Method "type"' do
    class BaBar
      include Hancock::Validations
      attr_accessor :bar, :babar

      validates :bar, type: :string
    end

    it 'raises and error if validation-arrt is not of expected type' do 
      class BaBar
        def initialize(args={})
          @bar = args[:bar]
          self.validate!
        end
      end
      expect { BaBar.new({bar: 1}) }.to raise_error()
    end

    it 'Dont raises and error if validation-arrt is ot expected type' do 
      class BaBar
        def initialize(args={})
          @bar = args[:bar]
          self.validate!
        end
      end
      expect { BaBar.new({bar: 'string'}) }.to_not raise_error()
    end
  end

  describe 'Method "inclusion_of"' do
    class BaBarFoo
      include Hancock::Validations
      attr_accessor :bar, :babar

      validates :bar, inclusion_of: [:babar, :foo]
    end

    it 'raises and error if validation-arrt is not inclusion of given array' do 
      class BaBarFoo
        def initialize(args={})
          @bar = args[:bar]
          self.validate!
        end
      end
      expect { BaBarFoo.new({bar: :bar}) }.to raise_error()
    end

    it 'Dont raises and error if validation-arrt inclusion of given array' do 
      class BaBarFoo
        def initialize(args={})
          @bar = args[:bar]
          self.validate!
        end
      end
      expect { BaBarFoo.new({bar: :foo}) }.to_not raise_error()
    end
  end
end