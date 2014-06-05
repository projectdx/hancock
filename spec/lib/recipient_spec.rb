require_relative '../spec_helper'

describe Hancock::Recipient do
  include_context "configs"
  include_context "variables"

  describe "#routing_order" do
    it 'defaults to 1' do
      subject.routing_order.should eq 1
    end

    it 'can be set' do
      subject.routing_order = 3
      subject.routing_order.should eq 3
    end
  end

  describe '#identifier' do
    it 'returns generated identifier by default' do
      allow_any_instance_of(described_class).to receive(:generate_identifier).and_return(:this_is_exciting)
      subject.identifier.should eq :this_is_exciting
    end

    it 'can be set' do
      subject.identifier = 'smithy mcsmitherson'
      subject.identifier.should eq 'smithy mcsmitherson'
    end
  end

  describe '#recipient_type' do
    it 'returns :signer by default' do
      subject.recipient_type.should eq :signer
    end

    it 'can be set' do
      subject.recipient_type = :swooner
      subject.recipient_type.should eq :swooner
    end
  end

  describe '#id_check' do
    it 'returns true by default' do
      subject.id_check.should be_true
    end

    it 'can be set' do
      subject.id_check = false
      subject.id_check.should be_false
    end
  end

  describe '#delivery_method' do
    it 'returns :email by default' do
      subject.delivery_method.should eq :email
    end

    it 'can be set' do
      subject.delivery_method = :aerokraft
      subject.delivery_method.should eq :aerokraft
    end
  end

  describe '.reload!' do
    it 'reloads recipients from DocuSign envelope' do    
      envelope.add_document(document)
      envelope.add_signature_request({ recipient: recipient, document: document, tabs: [tab] })
      envelope.add_signature_request({ recipient: recipient2, document: document, tabs: [tab] })
      envelope.save

      expect(described_class.reload!(envelope).map(&:email)).
        to match_array([recipient, recipient2].map(&:email))
    end
  end

  context 'validations' do
    it { should have_valid(:delivery_method).when(:email, :embedded, :offline, :paper) }
    it { should_not have_valid(:delivery_method).when(:goofy, nil, '') }

    it { should have_valid(:name).when('Soup Can Sam') }
    it { should_not have_valid(:name).when(nil, '') }

    it { should have_valid(:email).when('nerf@email.com', 'ooh+a+spider@what.is.an.email') }
    it { should_not have_valid(:email).when('dan@localhost', 'noobody', nil, '') }

    it { should have_valid(:id_check).when(true, false, nil) }
    it { should_not have_valid(:id_check).when('oh my yes', :true, '') }

    it { should have_valid(:recipient_type).when(*described_class::Types) }
    it { should_not have_valid(:recipient_type).when(:puppy, nil, '') }
  end
end