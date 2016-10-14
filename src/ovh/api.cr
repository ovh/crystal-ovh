require "json"

module Ovh
  class Api
    JSON.mapping(
      path: String,
      schema: String,
      description: String,
    )
  end
end
