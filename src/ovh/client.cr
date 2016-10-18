require "digest/sha1"
require "http/client"
require "json"

module Ovh
  class Client
    property endpoint : String
    property lose_time : Time::Span

    def initialize(app : Application)
      initialize(app.region, app.service, app.key, app.secret, app.consumer_key)
    end

    def initialize(region : Region, service : Service, @app_key : String, @app_secret : String, @consumer_key : String)
      begin
        @endpoint = region.endpoints[service]
        remote_timestamp = get_raw("/auth/time").to_i
        @lose_time = Time.utc_now - Time.epoch(remote_timestamp)
      rescue ArgumentError | RequestFailed
        raise InitializationError.new("Failed to retrieve timestamp from endpoint")
      end
    end

    {% for method in %w(delete get head post put) %}
      # Execute a {{method.id.upcase}} request.
      def {{method.id}}(path : String, body : JSON::Any | Nil ? = nil) : JSON::Any | Nil

        timestamp = (Time.utc_now + @lose_time).epoch()
        sig = signature({{method}}, path, body, timestamp)

        headers = HTTP::Headers {
          "Content-Type" => "application/json",
          "X-Ovh-Application" => @app_key,
          "X-Ovh-Consumer" => @consumer_key,
          "X-Ovh-Signature" => sig,
          "X-Ovh-Timestamp" => "#{timestamp}",
        }

        Ovh.{{method.id}}_json(@endpoint + path, headers, body) do |response|
          JSON.parse(response.body)
        end
      end
    {% end %}

    # Return the request signature.
    def signature(method, path, body, timestamp)
      signature = "#{@app_secret}+" \
                  "#{@consumer_key}+" \
                  "#{method.upcase}+" \
                  "#{@endpoint + path}" \
                  "+#{body}+" \
                  "#{timestamp}"
      return "$1$#{Digest::SHA1.hexdigest(signature)}"
    end

    # Execute a GET request and return the raw response body.
    private def get_raw(path)
      Ovh.get(@endpoint + path).body
    end
  end
end
