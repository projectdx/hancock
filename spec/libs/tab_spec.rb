require_relative '../spec_helper'

describe Hancock::Tab do
  include_context "configs"
  include_context "variables"

  it 'Should have default value of page_number' do 


    params = {
      type:            'type',
      coordinates:     [1,2], 
      label:           'label', 
     }
     Hancock::Tab.new(params).page_number.should_not be(nil)
  end

end