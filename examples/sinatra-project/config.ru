# require 'rack/logstash-writer'

$:.unshift File.expand_path("../../../lib" , __FILE__)

require 'rack/logstash-writer'

# Rails.root/config.ru
require ::File.expand_path('../lib/sinatra', __FILE__)

# use Rails::Rack::Debugger
# use Rack::ContentLength
use Rack::LogstashWriter, {url: "file:///home/org/Desktop/logsample" ,statuses: [*(200..600)], body_len: 0, #response_headers: {'User-agent'=>'ua-nimrod'},
                           request_headers: {'User-agent'=>'ua-nimrod'}} #"udp://localhost:5228" #  "udp://localhost:5228"
run Sinatra::Application
