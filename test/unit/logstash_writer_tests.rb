require_relative '../units_helper'

module Rack
    class LogstashWriterTests < UnitsHelper

      def test_udp
        con = LogstashWriter.new nil, "udp://localhost:8080"
        assert_equal(con.scheme , "udp")
      end

      def test_tcp
        con = LogstashWriter.new nil, "tcp://localhost:8080"
        assert_equal(con.scheme , "tcp")
      end

      def test_file
        con = LogstashWriter.new nil, "file:#{__FILE__}"
        assert_equal(con.scheme , "file")
      end

      def test_http_error
        begin
        con = LogstashWriter.new nil, "http://foo.com"
          rescue Exception => e
            puts e
            assert_equal(e.to_s , "This format of url is not accepted by this application.")

        end
      end



    end
end
