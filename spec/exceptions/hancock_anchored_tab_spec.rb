require_relative '../spec_helper'

describe Hancock::AnchoredTab do
  include_context "configs"

  it 'type, label are required' do 
    params = {
      offset: [2, 4]
    }
    lambda { Hancock::AnchoredTab.new(params) }.should raise_error(Hancock::ArgumentError)
    params = {
      type:   'type',
      offset: [2, 4]
    }
    lambda { Hancock::AnchoredTab.new(params) }.should raise_error(Hancock::ArgumentError)
    params = {
      type:   'type',
      offset: [2, 4]
    }
    lambda { Hancock::AnchoredTab.new(params) }.should raise_error(Hancock::ArgumentError)
  end

  it 'offset must be an array of integers' do 
    params = {
      label:  'label',
      type:   'type',
      offset: [2, '1234']
    }
    lambda { Hancock::AnchoredTab.new(params) }.should raise_error(Hancock::ArgumentUnvalidError)
    params = {
      label:  'label',
      type:   'type',
      offset: :unvalid_type
    }
    lambda { Hancock::AnchoredTab.new(params) }.should raise_error(Hancock::ArgumentUnvalidError)
  end

  it 'should not raise an exception if valid params given' do 
    params = {
      label:  'label',
      type:   'type',
      offset: [2, 1234]
    }
    lambda { Hancock::AnchoredTab.new(params) }.should_not raise_error()
  end

end