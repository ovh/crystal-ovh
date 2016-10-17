# crystal-ovh [![Build Status](https://travis-ci.org/xlucas/crystal-ovh.svg?branch=master)](https://travis-ci.org/xlucas/crystal-ovh)

Lightweight Crystal wrapper around OVH's APIs. Handles all the hard work including credential creation and requests signing.



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
  client = Ovh::Client.new( Ovh::Region::Europe, Ovh::Service::Ovh, "<key>", "<secret>", "<consumer_key>")
  client.get("/cloud/project").each do |id|
    puts "Project id : #{id}"
  end
rescue err : Ovh::InitializationError | Ovh::RequestFailed
  puts "Error raised : #{err}"
end
```


## Getting application credentials

#### 1. Create an application


To interact with APIs of a particular OVH service, your application needs to identify itself using an **application key** and an **application secret**. To get them, you need to register your application.

Depending on the service you plan to use, visit:

- [OVH Europe](https://eu.api.ovh.com/createApp/)
- [OVH North America](https://ca.api.ovh.com/createApp/)
- [SoyouStart Europe](https://eu.api.soyoustart.com/createApp/)
- [SoyouStart North America](https://ca.api.soyoustart.com/createApp/)
- [Kimsufi Europe](https://eu.api.kimsufi.com/createApp/)
- [Kimsufi North America](https://ca.api.kimsufi.com/createApp/)
- [RunAbove](https://api.runabove.com/createApp/)


#### 2. Authorize your application


To allow your application to access a customer account using the API on your behalf, you need a **consumer key**. When requesting this consumer key, you can set access rules to certain request paths.

Here is an example :

```crystal
  # Create an application
  app = Ovh::Application.new(Ovh::Region::Europe, Ovh::Service::Ovh, "<key>", "<secret>")

  # Allow GET and POST & PUT requests on "/cloud"
  app.add_rule("/cloud/*", Ovh::Rule::Read | Ovh::Rule::Write)
  # Allow DELETE requests on "/domain"
  app.add_rule("/domain/*", Ovh::Rule::Delete)

  # Register this application as a consumer
  app.register do |r|
    puts "Application consumer key is #{r.consumer_key}"
    puts "Visit #{r.validation_url} to activate it and press enter to continue..."
    gets
  end

  # Use your application
  client = Ovh::Client.new(app)
  ...
```

Returned **consumer key** should then be kept to avoid re-authenticating your end-user on each use.



## Supported APIs

### OVH Europe

- **Documentation**: https://eu.api.ovh.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://eu.api.ovh.com/console
- **Create application credentials**: https://eu.api.ovh.com/createApp/
- **Create script credentials** (all keys at once): https://eu.api.ovh.com/createToken/

### OVH North America

- **Documentation**: https://ca.api.ovh.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://ca.api.ovh.com/console
- **Create application credentials**: https://ca.api.ovh.com/createApp/
- **Create script credentials** (all keys at once): https://ca.api.ovh.com/createToken/

### So you Start Europe

- **Documentation**: https://eu.api.soyoustart.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://eu.api.soyoustart.com/console/
- **Create application credentials**: https://eu.api.soyoustart.com/createApp/
- **Create script credentials** (all keys at once): https://eu.api.soyoustart.com/createToken/

### So you Start North America

- **Documentation**: https://ca.api.soyoustart.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://ca.api.soyoustart.com/console/
- **Create application credentials**: https://ca.api.soyoustart.com/createApp/
- **Create script credentials** (all keys at once): https://ca.api.soyoustart.com/createToken/

### Kimsufi Europe

- **Documentation**: https://eu.api.kimsufi.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://eu.api.kimsufi.com/console/
- **Create application credentials**: https://eu.api.kimsufi.com/createApp/
- **Create script credentials** (all keys at once): https://eu.api.kimsufi.com/createToken/

### Kimsufi North America

- **Documentation**: https://ca.api.kimsufi.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://ca.api.kimsufi.com/console/
- **Create application credentials**: https://ca.api.kimsufi.com/createApp/
- **Create script credentials** (all keys at once): https://ca.api.kimsufi.com/createToken/

### Runabove

- **Community support**: https://community.runabove.com/
- **Console**: https://api.runabove.com/console/
- **Create application credentials**: https://api.runabove.com/createApp/
- **High level SDK**: https://github.com/runabove/python-runabove



## License

3-Clause BSD
