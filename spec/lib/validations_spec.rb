require_relative '../fixtures/validation_proxy'

describe Hancock::Validations do
  subject { ValidationProxy.new }

  describe ':unless conditional' do
    it 'runs validation if :unless returns false' do
      subject.is_mermaid = false
      subject.validate!
      expect(subject.errors_on(:legs)).to include 'must be set'
    end

    it 'skips validation if :unless returns true' do
      subject.is_mermaid = true
      subject.validate!
      expect(subject.errors_on(:legs)).not_to include 'must be set'
    end
  end

  describe ':if conditional' do
    it 'runs validation if :if returns true' do
      subject.is_mermaid = true
      subject.validate!
      expect(subject.errors_on(:tail)).to include 'must be set'
    end

    it 'skips validation if :if returns false' do
      subject.is_mermaid = false
      subject.validate!
      expect(subject.errors_on(:tail)).not_to include 'must be set'
    end
  end

  describe ':allow_nil option' do
    it 'runs validation if attribute not nil' do
      subject.num_of_feet = :monkeys
      subject.validate!
      expect(subject.errors_on(:num_of_feet)).to include 'must be of type: fixnum'
    end

    it 'skips validation if attribute is nil' do
      subject.num_of_feet = nil
      subject.validate!
      expect(subject.errors_on(:num_of_feet)).not_to include 'must be of type: fixnum'
    end
  end

  describe ':presence check' do
    it 'validates if attribute is present' do
      subject.favorite_cake = 'lemon and razor'
      subject.validate!
      expect(subject.errors_on(:favorite_cake)).not_to include 'must be set'
    end

    it 'does not validate if attribute is nil' do
      subject.favorite_cake = nil
      subject.validate!
      expect(subject.errors_on(:favorite_cake)).to include 'must be set'
    end

    it 'does not validate if attribute is blank' do
      subject.favorite_cake = ''
      subject.validate!
      expect(subject.errors_on(:favorite_cake)).to include 'must be set'
    end
  end

  describe ':type check' do
    it 'validates if attribute is of required type' do
      subject.num_of_feet = 18
      subject.validate!
      expect(subject.errors_on(:num_of_feet)).not_to include 'must be of type: fixnum'
    end

    it 'does not validate if attribute is not of required type' do
      subject.num_of_feet = 'fishes'
      subject.validate!
      expect(subject.errors_on(:num_of_feet)).to include 'must be of type: fixnum'
    end
  end

  describe ':inclusion_of check' do
    it 'validates if attribute is member of inclusion list' do
      subject.nose_hair_color = :green
      subject.validate!
      expect(subject.errors_on(:nose_hair_color)).not_to include "must be included in: [:white, :green]"
    end

    it 'does not validate if attribute is not member of inclusion list' do
      subject.nose_hair_color = :blue
      subject.validate!
      expect(subject.errors_on(:nose_hair_color)).to include "must be included in: [:white, :green]"
    end
  end
end