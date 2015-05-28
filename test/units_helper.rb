$:.unshift File.expand_path("../../lib" , __FILE__)
require 'minitest'
require "minitest/autorun"
require "minitest/mock"
require "rack/logstash-writer"
require 'rack'

# TODO - is there a real need for this
module Rack
  class UnitsHelper < Minitest::Test
  end
end