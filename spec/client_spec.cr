require "spec"
require "../src/ovh"

describe Ovh::Client do
  it "should have a time lose close to 0 second" do
    client = Ovh::Client.new(Ovh::Region::Europe.endpoints[:Ovh], "", "", "")
    client.lose_time.should be_close(0, 5)
  end
end
