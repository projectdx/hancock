shared_context "variables" do
  let(:envelope) { Hancock::Envelope.new }

  let(:doc) { File.open("#{SPEC_ROOT}/fixtures/test.pdf") }

  let(:document) { Hancock::Document.new( file: doc, name: "test", extension: "pdf", identifier: 123 ) }
  
  let(:recipient) { Hancock::Recipient.new({identifier: 222, name: "Owner", email: "kolya.bokhonko@gmail.com", routing_order: 1, delivery_method: :email, recipient_type: :signer}) }
  
  let(:tab) { Hancock::Tab.new(type: "sign_here", label: "Vas", coordinates: [2, 100], page_number: 1) }

  let(:file) { File.new("#{SPEC_ROOT}/fixtures/test.pdf") }

  let (:header) { { 'Accept' => 'json', 'X-DocuSign-Authentication' => 
        { 'Username' => Hancock.username, 'Password' => Hancock.password, 'IntegratorKey' => Hancock.integrator_key }.to_json 
      } }

  let (:bad_header) { { 'Accept' => 'json', 'X-DocuSign-Authentication' => 
        { 'Username' => Hancock.username, 'Password' => "123456", 'IntegratorKey' => Hancock.integrator_key }.to_json 
      } }

  let(:callback_xml) { File.open("#{SPEC_ROOT}/fixtures/callback.xml", "rb").read }

end