# coding: utf-8
$:.unshift File.expand_path('../lib', __FILE__)

require 'rack/logstash-writer/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-logstash-writer"
  spec.version       = Rack::LogstashWriter::VERSION
  spec.authors       = ["or garfunkel"]
  spec.email         = ["or@amobee.com"]
  spec.summary       = %q{Rack adapter for sending events to logstash server, from the chosen statuses code.}
  spec.description   = %q{Rack adapter for sending events to logstash server, from the chosen statuses code, can be writen to file/udp/tcp servers.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rake", "~> 10.0"

end
