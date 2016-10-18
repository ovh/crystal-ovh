require "ini"

module Ovh
  class Configuration
    NAME = "ovh.conf"

    @@initialized = false
    @@values = {} of String => Hash(String, String)

    def self.load(app_name)
      load_from_env(app_name)
      load_from_file(app_name)

      unless @@initialized
        raise ConfigurationError.new("Configuration not found")
      end
      unless @@values.has_key?(app_name)
        raise ConfigurationError.new("Application #{app_name} not found")
      end
      unless @@values[app_name].has_key?("consumer_key")
        @@values[app_name]["consumer_key"] = ""
      end
      return @@values[app_name]
    end

    private def self.load_from_env(app_name)
      unless @@initialized
        hash = {} of String => String
        begin
          @@initialized = true
          hash["region"] = ENV["OVH_REGION"]
          hash["service"] = ENV["OVH_SERVICE"]
          hash["key"] = ENV["OVH_APPLICATION_KEY"]
          hash["secret"] = ENV["OVH_APPLICATION_SECRET"]
          hash["consumer_key"] = ENV["OVH_APPLICATION_CONSUMER_KEY"]
        rescue e : KeyError
          unless e.to_s.includes?("OVH_APPLICATION_CONSUMER_KEY")
            @@initialized = false
          end
        end
        if @@initialized
          @@values[app_name] = hash
        end
      end
    end

    private def self.load_from_file(app_name)
      unless @@initialized
        [".", ENV["HOME"], "/etc"].each do |dir|
          path = "#{dir}/#{NAME}"
          if File.file?(path)
            @@values = INI.parse(File.read(path))
            @@initialized = true
            break
          end
        end
      end
    end
  end
end
