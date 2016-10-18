require "spec"
require "webmock"
require "../src/ovh"

describe Ovh::Application do
  Spec.before_each do
    WebMock.reset
  end

  {% for region in %w(Europe NorthAmerica) %}
    context "the region is {{region.id}}" do
      region = Ovh::Region::{{region.id}}

      {% for service in %w(Kimsufi Ovh RunAbove SoyouStart) %}
        context "the service is {{service.id}}" do
          service = Ovh::Service::{{service.id}}
          endpoint = region.endpoints[service]

          it "should not list APIs if unavailable" do
            WebMock.stub(:get, endpoint + "/")
                   .to_return(status: 200, body: "")
            application = Ovh::Application.new(region, service, "", "")
            expect_raises(Ovh::RequestFailed) do
              application.consumable_apis
            end
          end

          it "should list APIs if available" do
            WebMock.stub(:get, endpoint + "/")
                   .to_return(status: 200,
              body: %({"apis":[{"path": "/path", "schema": "/schema", "description": "api info"}]})
            )
            application = Ovh::Application.new(region, service, "", "")
            application.consumable_apis.each do |api|
              api.path.should eq("/path")
              api.schema.should eq("/schema")
              api.description.should eq("api info")
            end
          end

          it "should successfully register for a consumer key" do
            WebMock.stub(:post, endpoint + "/auth/credential")
              .to_return(status: 200,
              body: %({"validationUrl": "url", "consumerKey": "abc", "state": "ok"})
            )
            application = Ovh::Application.new(region, service, "", "")
            registration = application.register("localhost") do |r|
              r.validation_url.should eq("url")
              r.consumer_key.should eq("abc")
              r.state.should eq("ok")
            end
          end

          it "should unsuccessfully register for a consumer key" do
            WebMock.stub(:post, endpoint + "/auth/credential")
              .to_return(status: 500)
            application = Ovh::Application.new(region, service, "", "")
            expect_raises(Ovh::RequestFailed) do
              registration = application.register("localhost") do |r|
              end
            end
          end

        end
      {% end %}

    end
  {% end %}
end
