require_relative '../units_helper'

module Rack
    class LogstashWriterTests < UnitsHelper

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


      def test_general_working_no_error
        logstash = LogstashWriter.new JSONServer.new, url: "udp://localhost:8086"
        s,h,b = logstash.call ENV
        assert_equal(s , 200)
        assert_equal(h , {"Content-Type" => "application/json"})
        assert_equal(b , ['{ "message" : "Hello!" }'])
      end

      def test_udp
          logstash = LogstashWriter.new JSONServerError.new, url:"udp://localhost:8086"
          s, h, b = logstash.call ENV
          assert_equal(s , 555)
          assert_equal(h , {"Content-Type" => "application/json"})
          assert_equal( b.class.to_s ,"Rack::BodyProxy" )
      end

      def test_file
        begin
          logstash = LogstashWriter.new JSONServerError.new, url:"file://not_existing_file"
          s, h, b = logstash.call ENV
          b.close
        rescue Exception => e
          puts e
          assert_includes(e.to_s , "No such file or directory @ rb_sysopen -")
        end
      end

    end
end
