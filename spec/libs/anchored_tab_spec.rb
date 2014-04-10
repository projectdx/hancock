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

  it 'to_h method Should generate proper hash' do 
    def to_h
      tmp_hash = {
        :anchorString       => 'anchor_text',
        :anchorXOffset      => offset[0],
        :anchorYOffset      => offset[1],
        :IgnoreIfNotPresent => 1,
        :pageNumber         => page_number
      }
      params = {
        type:   tmp_hash[:anchorString],
        offset: [tmp_hash[:anchorXOffset],tmp_hash[:anchorYOffset]], 
        type:   tmp_hash[:anchorString]
      }
      Hancock::AnchoredTab.new(params).to_h.should eq(tmp_hash)
    end
  end

end