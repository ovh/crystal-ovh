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
        raise InitializationError.new "Failed to retrieve timestamp from endpoint"
      end
    end

    {% for method in %w(delete get head post put) %}
      # Executes a {{method.id.upcase}} request.
      def {{method.id}}(path, body : JSON::Any | Nil ? = nil) : JSON::Any | Nil
        now = Time.utc_now
        sig = signature({{method}}, path, body, now)

        headers = HTTP::Headers {
          "Content-Type" => "application/json",
          "X-Ovh-Application" => @app_key,
          "X-Ovh-Signature" => sig,
          "X-Ovh-Timestamp" => "#{now.epoch}",
        }

        HTTP::Client.{{method.id}}(@endpoint + path, body: body, headers: headers) do |response|
          unless response.success?
            raise RequestFailed.new "Unexpected response " \
                                    "(code=#{response.status_code}, body=#{response.body})"
          end
          if response.body_io?
            JSON.parse(response.body_io.gets_to_end)
          end
        end
      end
    {% end %}

    # Retrieve available APIs.
    def apis
      json = get_raw("/")
      if json.nil?
        raise RequestFailed.new "Missing response body while retrieving the list of APIs"
      end
      Array(Ovh::Api).from_json(json, root: "apis")
    end

    # Get request signature.
    def signature(method, path, body, time)
      signature = "#{@app_secret}+" \
                  "#{@consumer_key}+" \
                  "#{method.upcase}+" \
                  "#{@endpoint + path}" \
                  "+#{body}+" \
                  "#{(time + @lose_time).epoch}"
      return "$1$#{Digest::SHA1.hexdigest(signature)}"
    end

    # Executes a GET request and return the raw response body.
    private def get_raw(path)
      response = HTTP::Client.get(@endpoint + path)
      unless response.success?
        raise RequestFailed.new "Unexpected response " \
                                "(code=#{response.status_code}, body=#{response.body})"
      end
      response.body
    end
  end
end
