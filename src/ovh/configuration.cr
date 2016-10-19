require "ini"

module Ovh
  class Configuration
    ENV_PREFIX = "OVH"
    NAME       = "ovh.conf"
    VARS       = {
      :Endpoint    => "endpoint",
      :Key         => "application_key",
      :Secret      => "application_secret",
      :ConsumerKey => "consumer_key",
    }

    @@loaded = false
    @@endpoints = {} of String => Hash(String, String)
    @@default_endpoint = ""

    def self.load(endpoint)
      unless @@loaded
        load_from_env()
        load_from_file()
      end

      begin
        if endpoint.empty? && @@default_endpoint.empty?
          raise ConfigurationError.new("Missing configuration for default endpoint")
        elsif endpoint.empty?
          return @@default_endpoint, @@endpoints[@@default_endpoint]
        else
          return endpoint, @@endpoints[endpoint]
        end
      rescue KeyError
        raise ConfigurationError.new("Missing configuration for requested endpoint")
      end
    end

    private def self.load_from_env
      hash = {} of String => String
      begin
        @@loaded = true
        VARS.values.each do |v|
          hash[v] = ENV["#{ENV_PREFIX}_#{v.upcase}"]
        end
      rescue e : KeyError
        unless e.to_s.includes?("#{ENV_PREFIX}_#{VARS[:ConsumerKey].upcase}")
          @@loaded = false
        end
      end
      if @@loaded
        @@default_endpoint = hash[VARS[:Endpoint]]
        @@endpoints[@@default_endpoint] = hash
      end
    end

    private def self.load_from_file
      unless @@loaded
        [".", ENV["HOME"], "/etc"].each do |dir|
          path = "#{dir}/#{NAME}"
          if File.file?(path)
            @@endpoints = INI.parse(File.read(path))
            @@loaded = true
            break
          end
        end
        if @@loaded
          begin
            @@default_endpoint = @@endpoints["default"]["endpoint"]
          rescue KeyError
          end
        end
      end
    end
  end
end
