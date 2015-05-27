$:.unshift File.expand_path("../../lib/rack" , __FILE__)
require 'minitest'
require "minitest/autorun"
require "minitest/mock"
require "logstash-writer"

# TODO - is there a real need for this
module Rack
  class UnitsHelper < Minitest::Test
  end
end