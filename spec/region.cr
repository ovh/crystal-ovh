require "spec"
require "../src/ovh"

describe Ovh::Region do
  {% for region in %w(Canada Europe) %}
      {% for service in %w(Kimsufi Ovh SoyouStart) %}
        it "should have the {{service.id}} endpoint for {{region.id}}" do
          endpoints = Ovh::Region::{{region.id}}.endpoints[:{{service}}]
          endpoints.should eq(
            "https://#{{{region}}.downcase[0..1]}.api.#{{{service}}.downcase}.com/1.0"
          )
        end
      {% end %}
    {% end %}

  it "should have the RunAbove endpoint for Canada and Europe" do
    Ovh::Region::Canada.endpoints[:RunAbove].should eq(
      Ovh::Region::Europe.endpoints[:RunAbove]
    )
    Ovh::Region::Canada.endpoints[:RunAbove].should eq(
      "https://api.runabove.com/1.0"
    )
  end
end
