# Rack::Logstashwriter
[![Build Status](https://magnum.travis-ci.com/kontera-technologies/rack-logstash-writer.svg?token=njzKjnEfT4vj1w52zQEu&branch=master)](https://magnum.travis-ci.com/kontera-technologies/rack-logstash-writer)

The gem creates a rack layer for logging in case of exceptions. - log to file/udp/tcp

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-logstash-writer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-logstas-hwriter

## Usage
##### You can find it all in the examples directory

Rack/Rails/Sinatra:

Add to the gemfile

    $   source "http://gems.kontera.com"
    $   gem "rack-logstash-writer"
    
Add to the config.ru
 
    $   require 'rack/logstash-writer'
    $   use Rack::LogstashWriter,<URI for the wanted location> (etc : "tcp://localhost:5228" #"udp://localhost:5228" # "file:///home/org/Desktop/logsample")
    $   run <application> (etc : Sinatra::Application, run Rails.application, run JSONServerError.new)
    
Paramters for the 'use' 
Original function : def initialize app, url, opts = {} , statuses_arr = [*(500..600)] , body_trim_num = 1000
    
    $   app =  Rack::LogstashWriter(mandatory)
    $   uri,string(mandatory), etc : "tcp://localhost:5228" #"udp://localhost:5228" # "file:///home/org/Desktop/logsample"
    $   opts(optional) - opts[:extra_request_headers] , opts[:extra_response_headers], hashes of paramters to print in the log { |<name to find>, <name to print>| }
    $   statuses_arr(optional) - statuses for logging, etc : [500], [500..600 , 404] 
    $   body_trim_num, number(optional) - number of letters for 
 
Examples for use lines

    $   use Rack::LogstashWriter, "file:////home/org/Desktop/logsample", {}, [*(500..600) . *(400..409)], 1000
    $   use Rack::LogstashWriter,  "tcp://localhost:5228" 

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rack-logstashwriter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
