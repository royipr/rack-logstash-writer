# Rack::Logstashwriter

Rack adapter for sending events to logstash server.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-logstash-writer'
```
And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-logstash-writer

## Usage
##### You can find it all in the examples directory

Add to the config.ru
 
```ruby
require 'rack/logstash-writer'

use Rack::LogstashWriter,{url: "tcp://localhost:5228"} # udp and files schemes are also avaliable.

use Rack::LogstashWriter , {url: "file:///home/org/Desktop/logsample", # required, udp and files schemes are also avaliable. no default values.
    request_headers: {'head1'=>'head1'}, # optional, parameters to add to the report from the request headers. default nil
    response_headers: {'head1'=>'head1'}, # optional, parameters to add to the report from the responce headers. default nil
    statuses: [*(500..600)], # optional, send events to log stash only for those statuses. default [*(500..600)] 
    body_len: 50 # optional, include the first given chars from the body. default 1000
    }
    
run Proc.new {[200, {"Content-Type" => "application/json"}, ['{ "message" : "Hello!" }']]}
```
## Contributing

1. Fork it ( https://github.com/[my-github-username]/rack-logstashwriter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
