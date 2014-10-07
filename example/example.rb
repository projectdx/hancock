#!/usr/bin/env ruby
require 'bundler/setup'
require 'hancock'

Hancock.configure do |c|
   c.oauth_token  = 'oauth_token_here' # NOT integrator key!
   c.account_id   = 'account_id_here' # NOT integrator key!
   c.endpoint     = 'https://demo.docusign.net/restapi'
   c.api_version  = 'v2'

  # c.email_template = {
  #   :subject => 'sign these',
  #   :blurb => 'click the link to sign'
  # }
end


document1 = Hancock::Document.new({
  file: File.open(File.expand_path('DocuSign API.docx', File.dirname(__FILE__)))
  # data: 'Base64 Encoded String', # required if no file, invalid if file
  # name: 'whatever.pdf', # optional if file, defaults to basename
  # extension: 'pdf', # optional if file, defaults to path extension
})

document2 = Hancock::Document.new({
  file: File.open(File.expand_path('DocuSign API.docx', File.dirname(__FILE__)))
  # data: 'Base64 Encoded String', # required if no file, invalid if file
  # name: 'whatever.pdf', # optional if file, defaults to basename
  # extension: 'pdf', # optional if file, defaults to path extension
})

document3 = Hancock::Document.new({
  file: File.open(File.expand_path('DocuSign API.docx', File.dirname(__FILE__)))
  # data: 'Base64 Encoded String', # required if no file, invalid if file
  # name: 'whatever.pdf', # optional if file, defaults to basename
  # extension: 'pdf', # optional if file, defaults to path extension
})


# create recepients and add them to envelope
recipient1 = Hancock::Recipient.new({
  name: 'Owner 1',
  email: 'test@example.com',
  # id_check: true,
  # delivery_method: email, # email, embedded, offline, paper
  # routing_order: 1
})

tab1 = Hancock::AnchoredTab.new({
  type: 'sign_here',
  anchor_text: 'DocuSign API'
})
tab2 = Hancock::AnchoredTab.new({
  type: 'date_signed',
  anchor_text: 'Test 1234'
})

envelope = Hancock::Envelope.new({
  email: {
    subject: 'Hello there',
    blurb: 'Please sign this!'
  }
})

envelope.documents = [document1, document2, document3]

envelope.add_signature_request(
  {
    recipient: recipient1,
    document: document1,
    tabs: [tab1, tab2],
  }
)

p envelope.send!
