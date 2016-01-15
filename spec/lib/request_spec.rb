describe Hancock::Request do
  before(:each) do
    allow(Hancock).to receive(:oauth_token).and_return("a_tokeny_value")
  end

  describe ".send_post_request" do
    subject { instance_double(Hancock::Request) }

    it "creates an instance and sends the request" do
      expect(described_class).to receive(:new)
        .with(
          :type => :post,
          :url => "a_url",
          :custom_headers => {"custom" => "header"},
          :body => "a_body"
        ).and_return(subject)
      expect(subject).to receive(:send_request)
      described_class.send_post_request("a_url", "a_body", "custom" => "header")
    end
  end

  describe ".send_put_request" do
    subject { instance_double(Hancock::Request) }

    it "creates an instance and sends the request" do
      expect(described_class).to receive(:new)
        .with(
          :type => :put,
          :url => "a_url",
          :custom_headers => {"custom" => "header"},
          :body => "a_body"
        ).and_return(subject)
      expect(subject).to receive(:send_request)
      described_class.send_put_request("a_url", "a_body", "custom" => "header")
    end
  end

  describe ".send_get_request" do
    subject { instance_double(Hancock::Request) }

    it "creates an instance and sends the request" do
      expect(described_class).to receive(:new)
        .with(:type => :get, :url => "a_url")
        .and_return(subject)
      expect(subject).to receive(:send_request)
      described_class.send_get_request("a_url")
    end
  end

  describe ".send_delete_request" do
    subject { instance_double(Hancock::Request) }

    it "creates an instance and sends the request" do
      expect(described_class).to receive(:new)
        .with(
          :type => :delete,
          :url => "a_url",
          :custom_headers => {"custom" => "header"},
          :body => "a_body"
        ).and_return(subject)
      expect(subject).to receive(:send_request)
      described_class.send_delete_request("a_url", "a_body", "custom" => "header")
    end
  end

  describe "#initialize" do
    it "uses default headers" do
      subject = described_class.new(:type => :foo, :url => :bar)

      expect(subject.headers).to eq({
        "Accept" => "application/json",
        "Authorization" => "bearer a_tokeny_value",
        "Content-Type" => "application/json"
      })
    end

    it "allows custom headers to override default headers" do
      custom_headers = {
        "Nature" => "secret",
        "Accept" => "EvEryThinG!"
      }
      subject = described_class.new(
        :type => :foo,
        :url => :bar,
        :custom_headers => custom_headers
      )

      expect(subject.headers).to eq({
        "Nature" => "secret",
        "Accept" => "EvEryThinG!",
        "Authorization" => "bearer a_tokeny_value",
        "Content-Type" => "application/json"
      })
    end

    it "allows a body to be specified" do
      subject = described_class.new(
        :type => :foo,
        :url => :bar,
        :custom_headers => {},
        :body => "the body"
      )
      expect(subject.body).to eq("the body")
    end

    it "generates the uri" do
      allow(Hancock).to receive(:endpoint).and_return("3ndp0int")
      allow(Hancock).to receive(:api_version).and_return("l@test")
      allow(Hancock).to receive(:account_id).and_return("acc0unt")

      subject = described_class.new(:type => :foo, :url => "/awesome_path")

      expect(subject.uri).to eq("3ndp0int/l@test/accounts/acc0unt/awesome_path")
    end
  end

  describe "#send_request" do
    subject {
      described_class.new(
        :type => :patch,
        :url => "a_url",
        :custom_headers => {},
        :body => "the content"
      )
    }

    before(:each) do
      allow(subject).to receive(:uri).and_return("the_uri")
      allow(subject).to receive(:headers).and_return({ :some => "headers" })
    end

    context "for JSON responses" do
      body = '{ "a": "response" }'

      before(:each) do
        stub_request(:patch, /the_uri/)
          .with(
            :headers => { :some => "headers" },
            :body => "the content"
          )
          .to_return(
            :headers => { :content_type => "application/json; charset=utf-8" },
            :body => body,
          )
      end

      it "returns the parsed response" do
        expect(subject.send_request).to eq(JSON.parse(body))
      end
    end

    context "for non-JSON responses" do
      body = '{ "a": "response" }'

      before(:each) do
        stub_request(:patch, /the_uri/)
          .with(
            :headers => { :some => "headers" },
            :body => "the content"
          )
          .to_return(
            :body => body,
          )
      end

      it "returns the body" do
        expect(subject.send_request).to eq(body)
      end
    end

    context "for requests with a non-200-level HTTP status" do
      before(:each) do
        stub_request(:patch, /the_uri/)
          .with(
            :headers => { :some => "headers" },
            :body => "the content"
          )
          .to_return(
            :status => 404,
          )
      end

      it "raises an exception" do
        expect{ subject.send_request }.to raise_error(Hancock::Request::RequestError)
      end
    end

    context "for requests that contain an errorCode" do
      before(:each) do
        stub_request(:patch, /the_uri/)
          .with(
            :headers => { :some => "headers" },
            :body => "the content"
          )
          .to_return(
            :headers => { :content_type => "application/json" },
            :status => 200,
            :body => body
          )
      end

      context "when the errorCode is a top-level key" do
        let(:body) { '{ "errorCode": "REQU3STLY_NO-BUENo" }' }

        it "raises an exception" do
          expect{ subject.send_request }.to raise_error(Hancock::Request::RequestError)
        end
      end

      context "when the errorCode is nested" do
        let(:body) {
          {
            "someResultsForYou" => [
              { "foo" => "bar" },
              {
                "nestedStuff" => {
                  "errorCode" =>"REQU3STLY_NO-BUENo",
                  "message" => "Trust not the 200"
                }
              }
            ]
          }.to_json
        }

        it "raises an exception" do
          expect{ subject.send_request }.to raise_error(Hancock::Request::RequestError)
        end
      end

      context "when the errorCode is 'SUCCESS'" do
        let(:body) {
          { "errorCode" =>"SUCCESS" }.to_json
        }

        it "does not raise an exception" do
          expect{ subject.send_request }.not_to raise_error
        end
      end
    end
  end
end
