module Ovh
  enum Region
    Europe
    NorthAmerica

    def endpoints
      case self
      when Region::NorthAmerica
        {
          Service::Kimsufi    => "https://ca.api.kimsufi.com/1.0",
          Service::Ovh        => "https://ca.api.ovh.com/1.0",
          Service::SoyouStart => "https://ca.api.soyoustart.com/1.0",
          Service::RunAbove   => "https://api.runabove.com/1.0",
        }
      when Region::Europe
        {
          Service::Kimsufi    => "https://eu.api.kimsufi.com/1.0",
          Service::Ovh        => "https://eu.api.ovh.com/1.0",
          Service::SoyouStart => "https://eu.api.soyoustart.com/1.0",
          Service::RunAbove   => "https://api.runabove.com/1.0",
        }
      else
        return {} of Service => String
      end
    end
  end
end
