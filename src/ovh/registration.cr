require "json"

module Ovh
  class Registration
    JSON.mapping(
      consumer_key: {key: "consumerKey", type: String},
      validation_url: {key: "validationUrl", type: String},
      state: String,
    )
  end
end
