require "./consumer/request"
require "digest/sha1"
require "http/client"
require "json"

module Ovh
  class Client
    property app_key : String
    property app_secret : String
    property app_consumer_key : String
    property endpoint : String
    property lose_time : Time::Span

    # Create a new Client from the configuration.
    def initialize(endpoint_key = "")
      endpoint_key, conf = Configuration.load(endpoint_key)
      initialize(
        endpoint_key,
        conf[Configuration::VARS[:Key]],
        conf[Configuration::VARS[:Secret]],
        conf.has_key?(Configuration::VARS[:ConsumerKey]) ? conf[Configuration::VARS[:ConsumerKey]] : "",
      )
    end

    def initialize(endpoint_key : String, @app_key : String, @app_secret : String, @app_consumer_key : String = "")
      begin
        @endpoint = Ovh::ENDPOINTS[endpoint_key]
        remote_timestamp = get_raw("/auth/time").to_i
        @lose_time = Time.utc_now - Time.epoch(remote_timestamp)
      rescue ArgumentError
        raise RequestFailed.new("Failed to retrieve timestamp from endpoint")
      end
    end

    # Retrieve available APIs.
    def apis
      Ovh.get_json(@endpoint + "/") do |response|
        Array(Ovh::Api).from_json(response.body, root: "apis")
      end
    end

    # Create a new consumer request using client's endpoint.
    def consumer_request
      Consumer::Request.new(@endpoint, @app_key)
    end

    {% for method in %w(delete get head post put) %}
      # Execute a {{method.id.upcase}} request.
      def {{method.id}}(path : String, body : JSON::Any | Nil ? = nil) : JSON::Any | Nil

        timestamp = (Time.utc_now + @lose_time).epoch()
        sig = signature({{method}}, path, body, timestamp)

        headers = HTTP::Headers {
          "Content-Type" => "application/json",
          "X-Ovh-Application" => @app_key,
          "X-Ovh-Consumer" => @app_consumer_key,
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
                  "#{@app_consumer_key}+" \
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
