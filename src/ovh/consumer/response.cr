require "json"

module Ovh
  class Consumer::Response
    JSON.mapping(
      consumer_key: {key: "consumerKey", type: String},
      validation_url: {key: "validationUrl", type: String},
      state: String,
    )
  end
end
