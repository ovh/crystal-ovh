module Ovh
  class Error < Exception
  end

  class EndpointUnreachable < Error
  end

  class InitializationError < Error
  end

  class RequestFailed < Error
  end
end
