puts File.expand_path("../lib" , __FILE__)
$:.unshift File.expand_path("../lib" , __FILE__)
require 'rack/logstash-writer'

class JSONServer
  def call(env)
    [200, {"Content-Type" => "application/json"}, ['{ "message" : "Hello!" }']]
  end
end

class JSONServerError
  def call(env)
    [500, {"Content-Type" => "application/json"}, ['{ "message" : "Goodbye mr error." }']]
  end
end


use Rack::LogstashWriter,"tcp://localhost:5228"# "file:////home/org/Desktop/logsample" #"udp://localhost:5228"

map '/hello.json' do
  run JSONServer.new
end

map '/goodbye.json' do
  run JSONServerError.new
end
