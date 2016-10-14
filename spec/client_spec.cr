require "spec"
require "../src/ovh"

describe Ovh::Client do
  {% for region in %w(Canada Europe) %}
    {% for service in %w(Kimsufi Ovh RunAbove SoyouStart) %}
      it "should have a time lose close to 0s for the {{service.id}} endpoint of {{region.id}}" do
        client = Ovh::Client.new(Ovh::Region::{{region.id}}.endpoints[:{{service.id}}], "", "", "")
        client.lose_time.should be_close(0, 5)
      end

      it "should be able to list paths for the {{service.id}} endpoint of {{region.id}}" do
        client =  Ovh::Client.new(Ovh::Region::{{region.id}}.endpoints[:{{service.id}}], "", "", "")
        client.apis.should_not eq(nil)
      end
    {% end %}
  {% end %}
end
