require 'rack/logstash-writer'

# Rails.root/config.ru
require ::File.expand_path('../lib/sinatra', __FILE__)

# use Rails::Rack::Debugger
# use Rack::ContentLength
use Rack::LogstashWriter, "tcp://localhost:5228" , {}, [*(400..600)]#"udp://localhost:5228" # "file:///home/org/Desktop/logsample"
run Sinatra::Application
