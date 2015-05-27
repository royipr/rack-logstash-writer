# Rack::Logstashwriter
##This isnot the correct location, please change this
[![Build Status](https://magnum.travis-ci.com/kontera-technologies/aws-scanner.svg?token=njzKjnEfT4vj1w52zQEu&branch=master)](https://magnum.travis-ci.com/kontera-technologies/aws-scanner)

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

just use the next 2 :
require 'rack/logstash-writer'
use Rack::Logstashwriter::StashMaker, Rack::Logstashwriter::ConnenectorManager.new("udp://localhost:1234?txt_file=/home/org/Desktop/logsample")

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rack-logstashwriter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
