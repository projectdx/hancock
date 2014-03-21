Hancock Signature Gem
=========================
Gem for submitting documents to DocuSign with electronic signature tabs.


Api Specification
------------------

<a name=".configure"/>
#### 1. Configuration

```ruby
Hancock.configure do |c|
  c.aws_credentials = {api_token: 'sdfsdfdsfds', secret_key: 'sdsdsfdsfdsfdsf'}
  c.logging_enabled = true|false
end
```

___
<a name="#submit_for_signature" />
#### 2. Submitting documents for signing
Providing the necessary information about signers, documents, this service places the indicated signature tabs for each signer in the proper places of the document.

```ruby
submit_for_signature!(email_fields, signers, documents)
```
------

##### Description
Creates the necessary payload and submits it to DocuSign


Key          | Description
---          | ---
email_fields | components necessary to create outgoing email to signers.
             | `subject`: subject of email
             | `body`: body of email; this could be plain text or html.
             | `html`: `false`: plain text body; `true`: html body.
signers      | collection of [Signer](#signers)
documents    | collection of [Document](#documents)


<a name="signers"></a>

#####Signer

```json
{
  "name"     : "Sally Drew",
  "email"    : "sally@drew.com",
  "id_check" : "true",
  "media"    : "online",
  "tabs"     : [Tab],
}
```

Key      | Description
---      | ---
namei    | Name of signer
email    | Email address of signer
id_check | (default true) true to enable [ID Check functionality](http://www.docusign.com/partner/docusign-id-check-powered-by-lexisnexis-risk-solutions)
media    | (online) media for delivery;
         | online: send through email and sign online
         | offline: sign offline on tablet
         | print: print physical copy and snail-mail
tabs     | collection of [Tab](#tabs)


<a name="documents"></a>
##### Document

```json
{
  "identifier" : "12309323",
  "name"       : "application-2001220323",
  "extension"  : "docx",
  "content"    : "BASE64+CONTENT+OF-DOCUMENT",
}
```

Key            | Description
---            | ---
identifier     | Unique document identifier for this envelope
name           | Filename of document
extension      | filename type (extension) - e.g., pdf, doc(x)
content        | document content encoded using Base64

<a name="tabs"></a>	
#### Tab

```json
{
  "type": "sign_here",				
  "position": {
    "anchor_text" : "Sally Field's Signature",
    "x"           : "-12",
    "y"           : "120"
  },
  "document_identifiers": ('all' or ["12300232", "2232323"]),
}
```

Key                 | Description
---                 | ---
type                | Type of tab to use [see here](http://www.docusign.com/p/RESTAPIGuide/RESTAPIGuide.htm#REST%20API%20References/Tab%20Parameters.htm%3FTocPath%3DREST%20API%20References|Send%20an%20Envelope%20or%20Create%20a%20Draft%20Envelope|Tab%20Parameters|_____0) where name is represented as underscores and without (Tab word).  For example, `sign_here`, `date_signed`, `first_name`, …etc.
position            | specifies the position relative to an `anchor` text on the page (origin: bottom-left) 
                    | `anchor_text`: String where tab should be anchored to
                    | `x`: horizontal offset from anchor text.
                    | `y`: vertical offset from anchor text.
document_identifiers|  This is mostly useful for anchor tabs where the same anchor text is used across documents.
                    | `all`: applies this tab to all documents in the payload.  
                    | `[]`: applies tab to the specified documents in collection. 


##### Return value

The method should return the following JSON structure

```json
{
  "status"     : "success|failure",
  "message"    : "failure message",
  "metadata"   : {
    "envelope_id" : "Envelope ID returned by DocuSign",
    "sent_at": "date sent",
    (TBD)... this could include specific information returned by docuSign that we need ...
  }
}
```

---

#### 3. Processing DocuSign Notification Callback 
DocuSign has the ability to make callbacks to a specified URI and provide status on an envelope and recepient.
This method will allow the client to register a callback uri and select which event to listen to. 
[See eventNotification for details](https://www.docusign.com/p/RESTAPIGuide/RESTAPIGuide.htm#REST%20API%20References/Send%20an%20Envelope.htm%3FTocPath%3DREST%20API%20References%7CSend%20an%20Envelope%20or%20Create%20a%20Draft%20Envelope%7C_____0)

```ruby
register_notifications(uri, events) 
```
------

##### Description

Key               | Description
---               | ---
uri               | Endpoint where DocuSign will call upon changes in envelope status
envelope_events   | a list of events to register for each envelope.
                  | `possible values`: sent, delivered, sigend, completed, declined, voided
recepient_events  | a list of events to register for each recepient.
                  | `possible values`: authentication_failed, auto_responded, completed, declined, delivered, sent

##### Return Value

The method should return the following JSON structure

```json
{
  "status" : "success|failure",
  "message": "failure message",
  "metadata": {

  }
}
```
