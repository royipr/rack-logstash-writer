require 'socket'
require 'uri'
require 'logstash/event'

module Rack

  class LogstashWriter

    def initialize app, url
      @app = app
      @uri = URI(url)
    end

    def call env
      @app.call(env).tap { |s,h,b|
        BodyProxy.new(b) { log(env, s, h, Time.now, b) } if (500..600).include? s.to_i
      }
    end

    private

    def device
      @device ||= begin
        case @uri.scheme
        when "file" then
          File.new(@uri.path,"a")
        when "udp" then
          UDPSocket.new.tap { |s| s.connect @uri.host, @uri.port}
        when "tcp" then
          TCPSocket.new @uri.host,@uri.port
        else
          raise "Unknown scheme #{@uri.scheme}"
        end
      end
    end

    # private
    def log(env, status, response_headers, began_at, body)
      data = {
        :body => body.join[0..1000],
        :method => env["REQUEST_METHOD"],
        :path => env["PATH_INFO"],
        :query_string => env["QUERY_STRING"],
        :status => status.to_i,
        :duration => (Time.now - began_at),
        :remote_addr => env['REMOTE_ADDR'],
        :request => request_line(env),
        :length => extract_content_length(response_headers)
      }

      event = LogStash::Event.new('@fields' => data, '@tags' => ['request'])
      begin
        device.puts event.to_json
      rescue Errno::EPIPE, Errno::EINVAL
        @device = nil
      end
    end

    def request_line env
      line = "#{env["REQUEST_METHOD"]} #{env["SCRIPT_NAME"]}#{env['PATH_INFO']}"
      line << "?#{env["QUERY_STRING"]}" if env["QUERY_STRING"] and ! env["QUERY_STRING"].empty?
      line << " #{env["SERVER_PROTOCOL"]}"
      line
    end

    def extract_content_length headers
      value = headers[CONTENT_LENGTH] or return '-'
      value.to_s == '0' ? '-' : value
    end
  end
end
