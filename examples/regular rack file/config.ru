puts File.expand_path("../lib" , __FILE__)
$:.unshift File.expand_path("../lib" , __FILE__)
require 'rack/logstash-writer'

# Example for using this with rack
class JSONServer
  def call(env)
    [200, {"Content-Type" => "application/json"}, ['{ "message" : "Hello!" }']]
  end
end

class JSONServerError
  def call(env)
    [555, {"Content-Type" => "application/json"}, ['{ "message" : "Goodbye mr error, this is an error for sure." }']]
  end
end

use Rack::LogstashWriter , {url: "file:///home/org/Desktop/logsample", # or another examples   "udp://localhost:5228" #  "tcp://localhost:5228"
    request_headers: {'head1'=>'head1'},
    response_headers: {'head1'=>'head1'},
    statuses_arr: [*(500..600)] ,
    body_len: 50 }

map '/hello.json' do
  run JSONServer.new
end

map '/goodbye.json' do
  run JSONServerError.new
end

