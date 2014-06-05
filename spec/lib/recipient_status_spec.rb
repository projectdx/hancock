describe Hancock::RecipientStatus do
  let(:callback_xml) { File.open(fixture_path('callback.xml'), "rb").read }

  before do
    @noko = Nokogiri::XML.parse callback_xml
    @recipient_statuses = ['AuthenticationFailed', 'AutoResponded',
                          'Completed', 'Declined', 'Delivered', 'Sent'] #allowed statuses

    status_element = @noko.css('RecipientStatuses > RecipientStatus').first

    @recipient_status = Hancock::RecipientStatus.new(status_element.to_s)
  end

  it 'should have a proper status' do
    @recipient_status.status.should be_an_instance_of(String)

    expect(@recipient_statuses).to include @recipient_status.status.capitalize
  end

  it 'should have some identifier of String' do
    @recipient_status.recipient_id.should_not eq nil
    @recipient_status.recipient_id.should be_an_instance_of(String)
  end
end