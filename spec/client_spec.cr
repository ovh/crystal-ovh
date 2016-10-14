require "spec"
require "webmock"
require "../src/ovh"

describe Ovh::Client do
  {% for region in %w(Canada Europe) %}
    context "the region is {{region.id}}" do
      region = Ovh::Region::{{region.id}}

      {% for service in %w(Kimsufi Ovh RunAbove SoyouStart) %}
        context "the endpoint is {{service.id}}" do
          endpoint = region.endpoints[:{{service.id}}]

          it "should have a time lose around 0 second" do
            WebMock.stub(:get, endpoint + "/auth/time").
              to_return(status: 200, body: "#{Time.now.epoch}")
            client = Ovh::Client.new(endpoint, "", "", "")
            client.lose_time.total_seconds.should be_close(0, 5)
          end

          if endpoint == "https://eu.api.ovh.com/1.0"
            it "should have a valid signature" do
              client = Ovh::Client.new(endpoint, "",
                "EXEgWIz07P0HYwtQDs7cNIqCiQaWSuHF",
                "MtSwSrPpNjqfVSmJhLbPyr2i45lSwPU1",
              )
              client.lose_time = 0.second
              signature = client.signature("GET", "/domains/", nil, Time.epoch(1366560945))
              signature.should eq("$1$d3705e8afb27a0d2970a322b96550abfc67bb798")
            end
          end

          it "should be able to list APIs" do
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

        end
      {% end %}

    end
  {% end %}
end
