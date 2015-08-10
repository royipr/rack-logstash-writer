# require 'rack/logstash-writer'

 require ::File.expand_path('../../../lib/rack/logstash-writer', __FILE__)

# Rails.root/config.ru
require ::File.expand_path('../lib/sinatra', __FILE__)

# use Rails::Rack::Debugger
# use Rack::ContentLength
prc = Proc.new {|env| p env}
use Rack::LogstashWriter, {url: "tcp://localhost:5228" ,statuses: [*(200..600)], body_len: 100, response_headers: {'message' => 'This-is-a-message-man'},
                           request_headers: {'User-agent'=>'ua-nimrod'}, #"udp://localhost:5228" #   "file:///home/org/Desktop/logsample"
                           body_regex: {service_name: 'service_namev:(.*).*[,]?.*}' , proc: prc}
}

run Sinatra::Application
