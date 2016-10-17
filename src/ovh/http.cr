require "http/client"

module Ovh
  {% for method in %w(delete head get post put) %}
    def self.{{method.id}}(*args)
      response = HTTP::Client.{{method.id}}(*args)
      unless response.success?
        raise RequestFailed.new("Unexpected response (code=#{response.status_code}, body=#{response.body})")
      end
      return response
    end

    def self.{{method.id}}_json(*args)
      response = self.{{method.id}}(*args)
      begin
        yield response
      rescue ex: JSON::ParseException
        raise RequestFailed.new("Invalid JSON in response : #{ex}")
      end
    end
  {% end %}
end
