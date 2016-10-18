module Ovh
  class Error < Exception
  end

  class ConfigurationError < Error
  end

  class InitializationError < Error
  end

  class RequestFailed < Error
  end
end
