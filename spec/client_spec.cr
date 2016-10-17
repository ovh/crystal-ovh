require "spec"
require "webmock"
require "../src/ovh"

describe Ovh::Client do
  Spec.before_each do
    WebMock.reset
  end

  {% for region in %w(Canada Europe) %}
    context "the region is {{region.id}}" do
      region = Ovh::Region::{{region.id}}

      {% for service in %w(Kimsufi Ovh RunAbove SoyouStart) %}
        context "the endpoint is {{service.id}}" do
          endpoint = region.endpoints[:{{service.id}}]

          it "should not be initialized if remote time unavailable" do
            WebMock.stub(:get, endpoint + "/auth/time").
              to_return(status: 500, body: "invalid")
            expect_raises(Ovh::InitializationError) do
              Ovh::Client.new(endpoint, "", "", "")
            end
          end

          it "should be initialized if remote time is available" do
            WebMock.stub(:get, endpoint + "/auth/time").
              to_return(status: 200, body: "#{Time.now.epoch}")
            client = Ovh::Client.new(endpoint, "", "", "")
            client.lose_time.total_seconds.should be_close(0, 5)
          end

          it "should not list APIs if unavailable" do
            WebMock.stub(:get, endpoint + "/auth/time").
              to_return(status: 200, body: "#{Time.now.epoch}")
            WebMock.stub(:get, endpoint + "/").
              to_return(status: 500, body: "")
            client =  Ovh::Client.new(endpoint, "", "", "")
            expect_raises(Ovh::RequestFailed) do
              client.apis
            end
          end

          it "should list APIs if available" do
            WebMock.stub(:get, endpoint + "/auth/time").
              to_return(status: 200, body: "#{Time.now.epoch}")
            WebMock.stub(:get, endpoint + "/").
              to_return(status: 200,
                body: %({"apis":[{"path":"/path","schema":"/schema","description":"api info"}]})
              )
            client =  Ovh::Client.new(endpoint, "", "", "")
            client.apis.each do |api|
              api.path.should eq("/path")
              api.schema.should eq("/schema")
              api.description.should eq("api info")
            end
          end

          if endpoint == "https://eu.api.ovh.com/1.0"
            it "should emit a valid signature" do
              WebMock.stub(:get, endpoint + "/auth/time").
                to_return(status: 200, body: "#{Time.now.epoch}")

              client = Ovh::Client.new(endpoint,
                "application_key",
                "secret_key",
                "consumer_key",
              )

              signature = client.signature("GET", "/path", nil, 1366560945)
              signature.should eq("$1$8cece1edf879422954883c6980463690bc68e6d9")

              signature = client.signature("PUT", "/path", {"foo" => "bar"}.to_json, 1366560945)
              signature.should eq("$1$660bcf5fd296b310d84cf6acd1a45dc023d83938")
            end
          end

          {% for method in %w(delete head get post put) %}
            it "should handle a successful {{method.id}} request" do
              WebMock.stub(:get, endpoint + "/auth/time").
                to_return(status: 200, body: "#{Time.now.epoch}")
              WebMock.stub(:{{method.id}}, endpoint + "/path").
                to_return(status: 200, body: %({"foo": "bar"}))
              client =  Ovh::Client.new(endpoint, "", "", "")
              out = client.{{method.id}}("/path")
              unless out.nil?
                out["foo"].should eq("bar")
              end
            end

            it "should handle an unsuccessfull {{method.id}} request" do
              WebMock.stub(:get, endpoint + "/auth/time").
                to_return(status: 200, body: "#{Time.now.epoch}")
              WebMock.stub(:{{method.id}}, endpoint + "/path").
                to_return(status: 500)
              client =  Ovh::Client.new(endpoint, "", "", "")
              expect_raises(Ovh::RequestFailed) do
                client.{{method.id}}("/path")
              end
            end
          {% end %}

        end
      {% end %}

    end
  {% end %}
end
