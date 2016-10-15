module Ovh
  class Error < Exception
  end

  class InitializationError < Error
  end

  class RequestFailed < Error
  end
end
