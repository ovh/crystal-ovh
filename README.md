# crystal-ovh [![Build Status](https://travis-ci.org/xlucas/crystal-ovh.svg?branch=master)](https://travis-ci.org/xlucas/crystal-ovh)

Lightweight Crystal wrapper around OVH's APIs.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  ovh:
    github: xlucas/crystal-ovh
```


## Usage


```crystal
require "ovh"

begin
  # Consume APIs of a particular endpoint
  client = Ovh::Client.new(Ovh::Region::Europe.endpoints[:Ovh], "app_key", "app_secret", "consumer_key")

  # Print available APIs for this endpoint
  client.apis.each do |api|
    p api.path
  end

  # Use an API
  client.get("/cloud/project").each do |id|
    p id
  end
rescue err : Ovh::InitializationError | Ovh::RequestFailed
  puts "Got an error : #{err}"
end
```


## License

3-Clause BSD
