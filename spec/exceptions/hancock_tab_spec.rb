require_relative '../spec_helper'

describe Hancock::Tab do
  include_context "configs"

  it 'type, label are required' do 
    params = {
      coordinates: [2, 4]
    }
    lambda { Hancock::Tab.new(params) }.should raise_error(Hancock::ArgumentError)
    params = {
      type:        'type',
      coordinates: [2, 4]
    }
    lambda { Hancock::Tab.new(params) }.should raise_error(Hancock::ArgumentError)
    params = {
      type:        'type',
      coordinates: [2, 4]
    }
    lambda { Hancock::Tab.new(params) }.should raise_error(Hancock::ArgumentError)
  end

  it 'offset must be an array of integers' do 
    params = {
      label:       'label',
      type:        'type',
      coordinates: [2, '1234']
    }
    lambda { Hancock::Tab.new(params) }.should raise_error(Hancock::ArgumentUnvalidError)
    params = {
      label:       'label',
      type:        'type',
      coordinates: :unvalid_type
    }
    lambda { Hancock::Tab.new(params) }.should raise_error(Hancock::ArgumentUnvalidError)
  end

  it 'should not raise an exception if valid params given' do 
    params = {
      label:       'label',
      type:        'type',
      coordinates: [2, 1234]
    }
    lambda { Hancock::Tab.new(params) }.should_not raise_error()
  end

end