module Ovh
  class Error < Exception
  end

  class EndpointUnreachable < Error
  end

  class RequestFailed < Error
  end
end
