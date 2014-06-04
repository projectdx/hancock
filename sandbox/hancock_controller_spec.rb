
SPEC_ROOT = File.dirname(File.expand_path(__FILE__)) #it is better to specify it under your spec_helper, like: SPEC_ROOT = File.expand_path '../', __FILE__

FIXTURES = "#{SPEC_ROOT}" #/fixtures

require "#{SPEC_ROOT}/../spec_helper" # where is your spec_helper?

describe HancockController do

  let(:callback_xml) { File.open("#{FIXTURES}/callback.xml", "rb").read }

  let(:expected) { {:status => '', :recipient_statuses => [], :documents => []} }


  before :each do
    @request.env['RAW_POST_DATA'] = callback_xml
    post 'process_callback'
  end


  after :each do
    @request.env.delete('RAW_POST_DATA')
  end


  it "should log respectively" do

    @request.env['RAW_POST_DATA'] = callback_xml

    expect(Rails.logger).to receive(:debug).with('Recipient status:').at_least(1).times
    expect(Rails.logger).to receive(:debug).with('Sent').at_least(1).times

    expect(Rails.logger).to receive(:debug).with('Recipient id:').at_least(1).times
    expect(Rails.logger).to receive(:debug).with('f2622ce5-e52d-45ee-96a9-5f39439eba5b').at_least(1).times

    expect(Rails.logger).to receive(:debug).with('Recipient document:').at_least(1).times
    expect(Rails.logger).to receive(:debug).with({ documentId: anything(), name: 'test' })


    post 'process_callback'
    @request.env.delete('RAW_POST_DATA')

  end

  it "should return true json" do

    @response.should be_success

    response.header['Content-Type'].should include 'application/json'

  end

  it "should have correct order of json" do
    JSON.parse(response.body).keys.sort.should eq JSON.parse(expected.to_json).keys.sort
  end

  it "should have status element with correct type" do
    JSON.parse(response.body).should have_key('status')
    JSON.parse(response.body)['status'].should be_a_kind_of(expected[:status].class)
  end

  it "json should have a recipient_statuses collection" do
    JSON.parse(response.body).should have_key('recipient_statuses')
    JSON.parse(response.body)['recipient_statuses'].should be_a_kind_of(expected[:recipient_statuses].class)
  end

  it "json should have a documents collection" do
    JSON.parse(response.body).should have_key('documents')
    JSON.parse(response.body)['documents'].should be_a_kind_of(expected[:documents].class)
  end



end

