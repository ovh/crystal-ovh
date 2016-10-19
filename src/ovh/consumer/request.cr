require "./response"
require "http/client"
require "json"

module Ovh
  class Consumer::Request
    property endpoint : String
    property key : String

    def initialize(@endpoint, @key)
      @rules = [] of Hash(String, String)
    end

    # Add a new API access rule.
    def add_rule(path, mask)
      if mask.value & Rule::Delete.value != 0
        @rules << {"method" => "DELETE", "path" => path}
      end
      if mask.value & Rule::Read.value != 0
        @rules << {"method" => "GET", "path" => path}
      end
      if mask.value & Rule::Write.value != 0
        ["POST", "PUT"].each do |method|
          @rules << {"method" => method, "path" => path}
        end
      end
    end

    # Return a Consumer::Response.
    def execute(redirection_url = "")
      headers = HTTP::Headers{
        "Content-Type"      => "application/json",
        "X-Ovh-Application" => @key,
      }
      body = {"accessRules" => @rules, "redirection" => redirection_url}
      Ovh.post_json(@endpoint + "/auth/credential", headers, body.to_json) do |response|
        yield Consumer::Response.from_json(response.body)
      end
    end
  end
end
