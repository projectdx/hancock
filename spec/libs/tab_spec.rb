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

  it 'to_h method Should generate proper hash' do 
    def to_h
      tmp_hash = {
        :tabLabel    => 'label',
        :xPosition   => 1,
        :yPosition   => 2,
        :pageNumber  => page_number
      }
      params = {
        type:        tmp_hash[:tabLabel],
        coordinates: [tmp_hash[:xPosition],tmp_hash[:yPosition]], 
        type:        tmp_hash[:tabLabel]
      }
      Hancock::Tab.new(params).to_h.should eq(tmp_hash)
    end
  end

end