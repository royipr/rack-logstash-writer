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

use Rack::LogstashWriter, "tcp://localhost:5228" , {}, [*(500..600) , 700] , 0
# use Rack::LogstashWriter, "tcp://localhost:5228" #"udp://localhost:5228" # "file:////home/org/Desktop/logsample"

map '/hello.json' do
  run JSONServer.new
end

map '/goodbye.json' do
  run JSONServerError.new
end

