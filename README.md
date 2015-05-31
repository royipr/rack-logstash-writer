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
##### All the next examples have an example in config.ru.<some_name>.example files in the project root directory

Rack/Rails/Sinatra:

    $   require 'rack/logstash-writer'
    $   use Rack::LogstashWriter,<URI for the wanted location> (etc : "tcp://localhost:5228" #"udp://localhost:5228" # "file:///home/org/Desktop/logsample")
    $   run <application> (etc : Sinatra::Application, run Rails.application, run JSONServerError.new)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rack-logstashwriter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
