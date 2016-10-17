module Ovh
  enum Rule
    Delete = (1 << 0)
    Read   = (1 << 1)
    Write  = (1 << 2)
  end
end
