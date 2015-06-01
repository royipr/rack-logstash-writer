require 'rack/logstash-writer'

# Rails.root/config.ru
require ::File.expand_path('../config/environment', __FILE__)

use Rack::LogstashWriter, "tcp://localhost:5228" , {}, [*(100..600)]# "file:///home/org/Desktop/logsample"
# use Rack::LogstashWriter, "tcp://localhost:5228" , {} , [*(100..600)]#"tcp://localhost:5228" # #
run Rails.application
