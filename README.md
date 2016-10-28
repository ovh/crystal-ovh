# crystal-ovh [![Build Status](https://travis-ci.org/ovh/crystal-ovh.svg?branch=master)](https://travis-ci.org/ovh/crystal-ovh)

Lightweight Crystal wrapper around OVH's APIs. Handles all the hard work including credential creation and requests signing.



## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  ovh:
    github: ovh/crystal-ovh
```



## Usage


```crystal
require "ovh"

begin
  client = Ovh::Client.new("ovh-eu", "<key>", "<secret>", "<consumer_key>")
  client.get("/cloud/project").each do |id|
    puts "Project id : #{id}"
  end
rescue err : Ovh::RequestFailed
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


#### 2. Configure your application


In order to configure your application you can either :
- Use credentials direclty as literals.
- Use environment variables.
- Use a configuration file.


The easiest and safest way to use your application's credentials is to create an `ovh.conf` file :

```ini
[default]
; general configuration: default endpoint
endpoint=ovh-eu

[ovh-eu]
; configuration specific to 'ovh-eu' endpoint
application_key=my_app_key
application_secret=my_app_secret
;consumer_key=my_consumer_key
```

Depending on the API you want to use, you may set the ``endpoint`` to:

* ``ovh-eu`` for OVH Europe API
* ``ovh-ca`` for OVH North-America API
* ``soyoustart-eu`` for So you Start Europe API
* ``soyoustart-ca`` for So you Start North America API
* ``kimsufi-eu`` for Kimsufi Europe API
* ``kimsufi-ca`` for Kimsufi North America API
* ``runabove-ca`` for RunAbove API


The configuration loader will try to find this configuration file in multiple places. Lookups are achieved in the following order :

1. Current working directory: ``./ovh.conf``
2. Current user's home directory ``~/.ovh.conf``
3. System wide configuration ``/etc/ovh.conf``



If you decide to hold your configuration in the environment, the following variables are expected :
- `OVH_ENDPOINT`
- `OVH_APPLICATION_KEY`
- `OVH_APPLICATION_SECRET`
- `OVH_CONSUMER_KEY`

This configuration will be shared by all applications.

Now you can use :

```crystal
  # Using a specific endpoint
  client = Ovh::Client.new("ovh-eu")
```

Or

```crystal
  # Using default endpoint
  client = Ovh::Client.new()
```



#### 3. Authorize your application


To allow your application to access a customer account using the API on your behalf, you need a **consumer key**. When requesting this consumer key, you can set access rules to certain request paths.

Here is an example :

```crystal
require "ovh"

begin
  # Create an application from configuration
  client = Ovh::Client.new("ovh-eu")

  # Allow GET and POST & PUT requests for all "/cloud" calls
  ck_req = client.consumer_request()
  ck_req.add_rule("/cloud/*", Ovh::Rule::Read | Ovh::Rule::Write)

  # Allow DELETE requests for all "/domain" calls
  ck_req.add_rule("/domain/*", Ovh::Rule::Delete)

  # Register this application as a consumer.
  ck_req.execute() do |ck_rep|
    puts "Application consumer key is #{ck_rep.consumer_key}"
    puts "Visit #{ck_rep.validation_url} to activate it and press enter to continue..."
    gets
  end
rescue err: Ovh::ConfigurationError | Ovh::RequestFailed
  puts "Error raised : #{err}"
end
```

Returned **consumer key** should then be saved in your configuration to avoid re-authenticating your end-user on each use.



## Hacking

Make sure to use the latest version of crystal and to follow the [contribution guidelines](CONTRIBUTING.md).

### Code formatting

Code must be formatted with `crystal tool format`.

### Tests

If you develop a new feature, you must write tests for it. These are located in the `spec/` directory.

You can run them with `crystal spec -v`.




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

### RunAbove

- **Community support**: https://community.runabove.com/
- **Console**: https://api.runabove.com/console/
- **Create application credentials**: https://api.runabove.com/createApp/
- **High level SDK**: https://github.com/runabove/python-runabove



## License

3-Clause BSD
