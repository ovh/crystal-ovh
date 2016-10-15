require "digest/sha1"
require "http/client"
require "json"

module Ovh
  class Client
    property lose_time : Time::Span

    def initialize(@endpoint : String, @app_key : String, @app_secret : String, @consumer_key : String)
      begin
        remote_timestamp = get_raw("/auth/time").to_i
        @lose_time = (Time.utc_now - Time.epoch(remote_timestamp))
      rescue ArgumentError | RequestFailed
        raise InitializationError.new("Failed to retrieve timestamp from endpoint")
      end
    end

    {% for method in %w(delete get head post put) %}
      # Execute a {{method.id.upcase}} request.
      def {{method.id}}(path, body : JSON::Any | Nil ? = nil) : JSON::Any | Nil
        now = Time.utc_now
        sig = signature({{method}}, path, body, now)

        headers = HTTP::Headers {
          "Content-Type" => "application/json",
          "X-Ovh-Application" => @app_key,
          "X-Ovh-Signature" => sig,
          "X-Ovh-Timestamp" => "#{now.epoch}",
        }

        response = HTTP::Client.{{method.id}}(@endpoint + path, headers, body)
        unless response.success?
          raise RequestFailed.new("Unexpected response (code=#{response.status_code}, body=#{response.body})")
        end
        begin
          JSON.parse(response.body)
        rescue JSON::ParseException
          raise RequestFailed.new("Invalid JSON in response")
        end
      end
    {% end %}

    # Retrieve available APIs.
    def apis
      json = get_raw("/")
      if json.nil?
        raise RequestFailed.new("Empty response body while retrieving the list of APIs")
      end
      Array(Ovh::Api).from_json(json, root: "apis")
    end

    # Return the request signature.
    def signature(method, path, body, time)
      signature = "#{@app_secret}+" \
                  "#{@consumer_key}+" \
                  "#{method.upcase}+" \
                  "#{@endpoint + path}" \
                  "+#{body}+" \
                  "#{(time + @lose_time).epoch}"
      return "$1$#{Digest::SHA1.hexdigest(signature)}"
    end

    # Execute a GET request and return the raw response body.
    private def get_raw(path)
      response = HTTP::Client.get(@endpoint + path)
      unless response.success?
        raise RequestFailed.new("Unexpected response (code=#{response.status_code}, body=#{response.body})")
      end
      return response.body
    end
  end
end
