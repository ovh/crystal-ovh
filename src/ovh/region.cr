module Ovh
  enum Region
    Canada
    Europe

    def endpoints
      case self
      when Region::Canada
        {
          :Kimsufi    => "https://ca.api.kimsufi.com/1.0",
          :Ovh        => "https://ca.api.ovh.com/1.0",
          :SoyouStart => "https://ca.api.soyoustart.com/1.0",
          :RunAbove   => "https://api.runabove.com/1.0",
        }
      when Region::Europe
        {
          :Kimsufi    => "https://eu.api.kimsufi.com/1.0",
          :Ovh        => "https://eu.api.ovh.com/1.0",
          :SoyouStart => "https://eu.api.soyoustart.com/1.0",
          :RunAbove   => "https://api.runabove.com/1.0",
        }
      else
        return {} of Symbol => String
      end
    end
  end
end
