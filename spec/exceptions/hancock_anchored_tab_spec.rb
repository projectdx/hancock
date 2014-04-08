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

  it 'should not raise an exception if valid params given' do 
    params = {
      label:  'label',
      type:   'type',
      offset: [2, 1234]
    }
    lambda { Hancock::AnchoredTab.new(params) }.should_not raise_error()
  end

  it 'page_number should have default value of 1 it not supplied' do 
    params = {
      label:  'label',
      type:   'type',
      offset: [2, 1234]
    }
    h = Hancock::AnchoredTab.new(params)
    h.page_number.should eq(1)
  end

end