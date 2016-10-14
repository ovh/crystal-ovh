require "spec"
require "../src/ovh"

describe Ovh::Region do
  {% for region in %w(Canada Europe) %}
    {% for service in %w(Kimsufi Ovh SoyouStart) %}
      it "should have the {{service.id}} endpoint of {{region.id}}" do
        endpoints = Ovh::Region::{{region.id}}.endpoints[:{{service.id}}]
        endpoints.should eq("https://#{{{region}}.downcase[0..1]}.api.#{{{service}}.downcase}.com/1.0")
      end
    {% end %}

    it "should have the RunAbove endpoint of {{region.id}}" do
      Ovh::Region::{{region.id}}.endpoints[:RunAbove].should eq("https://api.runabove.com/1.0")
    end
  {% end %}
end
