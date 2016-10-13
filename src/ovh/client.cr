require "http/client"
require "json"

module Ovh
  class Client
    property lose_time

    def initialize(@endpoint : String, @app_key : String, @app_secret : String, @consumer_key : String)
      begin
        remote_timestamp = get_raw("/auth/time").to_i
        @lose_time = (Time.utc_now - Time.epoch(remote_timestamp)).total_seconds
      rescue ArgumentError | RequestFailed
        @lose_time = 0.0
        raise InitializationError.new("Failed to retrieve timestamp from endpoint")
      end
    end

    {% for method in %w(delete get head post put) %}
      # Executes a {{method.id.upcase}} request and yields the response to the block.
      def {{method.id}}(path, body : JSON::Any | Nil ? = nil) : JSON::Any | Nil
        HTTP::Client.{{method.id}}(@endpoint + path, body) do |response|
          unless response.success?
            raise RequestFailed.new("Unexpected response (code=#{response.status_code}, body=#{response.body})")
          end
          JSON.parse(response.body)
        end
      end
    {% end %}

    def get_raw(path) : String
      response = HTTP::Client.get(@endpoint + path)
      unless response.success?
        raise RequestFailed.new("Unexpected response (code=#{response.status_code}, body=#{response.body})")
      end
      response.body
    end
  end
end
