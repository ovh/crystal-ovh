require "spec"
require "../src/ovh"

describe Ovh::Region do
  {% for region in %w(Canada Europe) %}
    context "the region is {{region.id}}" do
      region = Ovh::Region::{{region.id}}

      {% for service in %w(Kimsufi Ovh SoyouStart) %}
        context "the service is {{service.id}}" do
          service = Ovh::Service::{{service.id}}
          endpoint = region.endpoints[service]

          it "should match the endpoint URL" do
            endpoint.should eq("https://#{{{region}}.downcase[0..1]}.api.#{{{service}}.downcase}.com/1.0")
          end
        end
      {% end %}

      context "the service is RunAbove" do
        it "should match the endpoint URL" do
          region.endpoints[Ovh::Service::RunAbove].should eq("https://api.runabove.com/1.0")
        end
      end
    end
  {% end %}
end
