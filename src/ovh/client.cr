require "http/client"
require "json"

module Ovh
  class Client
    def initialize(@endpoint, @app_key, @app_secret, @consumer_key)
      @http_client = HTTP::Client.new(@endpoint)
    end

    {% for method in %w(delete get head post put) %}
      # Executes a {{method.id.upcase}} request and yields the response to the block.
      def {{method.id}}(path, body : JSON::Any ? = nil) : JSON::Any
        @http_client.{{method.id}}(path, body) do |response|
          unless response.success?
            raise RequestFailed.new("Unexpected response (code=#{response.status_code}, body=#{response.body})")
          end
          JSON.parse(response.body)
        end
      end
    {% end %}
  end
end
