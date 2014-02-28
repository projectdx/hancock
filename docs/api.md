# rPace Signature Service

API Definition:

- [Request Signatures](#request_signatures)
- [Signature Status](#signautre_status)


<a name="request_signatures" />
### Request Signatures

**POST**: `/signatures/create`
Payload is a JSON structure as follows:

	{
	  email: {
	  	subject: text,
	  	body: text,
	  	html: boolean,     # true: default
	  },
	  signers: [signer],
	  documents: [document],
	}
	
Key | Description
--- | --- 
email | components necessary to create outgoing email to signers.
   | subject: subject of email
   | body: body of email; this could be plain text or html.
   | html: false for plain text body; true for html body.
signers | collection of [signers](#signers)
documents | collection of [documents](#documents)


#### Signer
<a name="signers"></a>

	{
	  name: text,	  
	  email: text,
	  id_check: boolean, 
	  media: (online|offline|print),
	  tabs: [tab],					# anchor tabs, applies to all documents
	}


Key | Description
--- | --- 
name* | Name of signer
email*   | Email address of signer
id_check | (default true) true to enable [ID Check functionality](http://www.docusign.com/partner/docusign-id-check-powered-by-lexisnexis-risk-solutions) 
media | (online) media for delivery;
 | online: send through email and sign online
 | offline: sign offline on tablet
 | print: print physical copy and snail-mail
tabs | collection of [tabs](#tabs)


#### Document
<a name="documents"></a>

 	{
	  identifier: text,
	  name: text,
	  body: text,
	  file_extension: text,
	}


Key | Description
--- | --- 
identifier* | Unique document identifier for this envelope
name*   | Filename of document
body* | document content encoded using Base64
file_extension | filename type (extension) - e.g., pdf, doc(x)

#### Tab
<a name="tabs"></a>	
	
	{
	  type: text,				
	  page: number,				
	  position: {
	  	mode: anchor|absolute,
	    anchor: string,
	    x: integer,
	    y: integer
	  },
	  document_identifiers: ('all' or []),
	  
	}

Key | Description
--- | --- 
type* | Type of tab to use [see here](http://www.docusign.com/p/RESTAPIGuide/RESTAPIGuide.htm#REST%20API%20References/Tab%20Parameters.htm%3FTocPath%3DREST%20API%20References|Send%20an%20Envelope%20or%20Create%20a%20Draft%20Envelope|Tab%20Parameters|_____0) where name is represented as underscores and without (Tab word).  For example, `sign_here`, `date_signed`, `first_name`, …etc.
page | page number where tab applies.
 | (optional for anchor mode) applies to all documents if not specified; otherwise, the tab only applies to the specified page.
 | (required for absolute mode).
 position | specifies the position relative to an `anchor` text on the page (origin: bottom-left) or to the top-left corner of the page.
  | mode: anchor: relative to anchor text; absolute: relative to entire page.
  | anchor: text to anchor tab to.
  | x: horizontal offset from origin.
  | y: vertical offset from origin.
document_identifier | a string value of 'all' applies this tab to all documents.  A collection of document identifiers applies this tab to the specified documents.  This is mostly useful for anchor tabs where the same anchor text is used across documents.



<a name="request_signatures" />
`/signatures/:id/status`


