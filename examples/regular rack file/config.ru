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

prc = Proc.new do |env|
  data = {}
  if env["REMOTE_HOST"] =='localhost'
    soc = Socket.ip_address_list.map {|s| s.ip_address}.reject {|s| s=='127.0.0.1'}.select {|s| 16 >(s.size) && (s.size)>10}.first
    data[:host] = "ip-#{soc.gsub(".","-")}"
  end
  data[:service_name] = Dir.pwd.split("/").last
  data
end

use Rack::LogstashWriter , {url: "file:///home/org/Desktop/logsample", # or another examples   "udp://localhost:5228" #  "tcp://localhost:5228"
    request_headers: {'head1'=>'head1'},
    response_headers: {'head1'=>'head1'},
    statuses: [*(500..600)] ,
    body_len: 50 ,
    body_regex: {service_name: 'service_namev:(.*).*[,]?.*}' , proc: prc}
}

map '/hello.json' do
  run JSONServer.new
end

map '/goodbye.json' do
  run JSONServerError.new
end

