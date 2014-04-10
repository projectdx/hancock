require_relative '../spec_helper'

describe Hancock::AnchoredTab do
  include_context "configs"
  include_context "variables"

  it 'Should have default value of page_number' do 


    params = {
      type:            'type',
      offset:          [1,2], 
      label:           'label', 
      anchor_text:     'anchor_text'
     }
     Hancock::AnchoredTab.new(params).page_number.should_not be(nil)
  end

  it 'Should have default value of anchor_text' do 
    params = {
      type:            'type',
      offset:          [1,2], 
      label:           'label'
     }
     at = Hancock::AnchoredTab.new(params)
     at.anchor_text.should eq(params[:label])
  end

end