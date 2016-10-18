require "http/client"
require "json"

module Ovh
  class Application
    property consumer_key : String
    property endpoint : String
    property key : String
    property region : Region
    property secret : String
    property service : Service

    def initialize(name)
      conf = Configuration.load(name)
      initialize(
        Region.parse(conf["region"]),
        Service.parse(conf["service"]),
        conf["key"],
        conf["secret"],
        conf["consumer_key"],
      )
    end

    def initialize(@region, @service, @key, @secret, @consumer_key = "")
      @endpoint = @region.endpoints[@service]
      @rules = [] of Hash(String, String)
    end

    # Retrieve consumable APIs.
    def consumable_apis
      Ovh.get_json(@endpoint + "/") do |response|
        Array(Ovh::Api).from_json(response.body, root: "apis")
      end
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

    # Register this application a new consumer.
    # Return the validation URL.
    def register(redirection_url)
      headers = HTTP::Headers{
        "Content-Type"      => "application/json",
        "X-Ovh-Application" => @key,
      }
      body = {"accessRules" => @rules, "redirection" => redirection_url}
      Ovh.post_json(@endpoint + "/auth/credential", headers, body.to_json) do |response|
        reg = Registration.from_json(response.body)
        @consumer_key = reg.consumer_key
        yield reg
      end
    end
  end
end
