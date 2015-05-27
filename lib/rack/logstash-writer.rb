require 'socket'
require 'uri'
require 'logstash/event'

module Rack

  class LogstashWriter

    attr_reader :scheme

    def initialize app, url
      @app = app
      @uri = URI(url)
      # @uri = URI(url)
      @host, @port, @scheme, @path = @uri.host, @uri.port, @uri.scheme, @uri.path
      correct_connection

    end

    def call env
      began_at = Time.now
      status, header, body = @app.call(env)
      if ( ( status.to_i >= 500) && (status.to_i <= 600) )
        #  TODO to remove this error
        puts "finally, I waited for ever ,here is an error!!"
        new_body = body
        body = BodyProxy.new(body) { log(env, status, header, began_at, new_body) }
      end
      [status, header, body]
    end

    private
    def correct_connection
      if  @scheme.eql? "file"
        @socket = IO::File.open(@path, "a")
      else
        if @scheme.eql? "udp"
          @socket = ::UDPSocket.new
          @socket.connect @host, @port
        else
          if @scheme.eql? "tcp"
            @socket = TCPSocket.new( @host , @port )
          else
            raise 'This format of url is not accepted by this application.'
          end
        end
      end
      @socket
    end

    def write msg
      correct_connection if (@socket.nil? || @socket.closed?)
      if @scheme.eql? "file"
        @socket.write(msg+"\n")
        @socket.close
        return
      end
      if @socket.respond_to?(:puts)
        @socket.puts(msg)
      else
        if @socket.respond_to?(:write)
          @socket.write(msg)
        else
          @socket << msg
        end
      end
    end

    # private
    def log(env, status, response_headers, began_at, body)
      now = Time.now
      # body max 1000 letters
      body = body.to_s[0,1000] if (body.to_s.length > 1000)
      data = {
          :body => body,
          :method => env["REQUEST_METHOD"],
          :path => env["PATH_INFO"],
          :query_string => env["QUERY_STRING"],
          :status => status.to_i,
          :duration => duration_in_ms(began_at, now).round(2),
          :remote_addr => env['REMOTE_ADDR'],
          :request => request_line(env),
          :length => extract_content_length(response_headers)
      }

      event = LogStash::Event.new('@fields' => data, '@tags' => ['request'])
      msg = event.to_json + "\n"
      write(msg)
    end

    def duration_in_ms(began, ended)
      (ended - began) * 1000
    end

    def request_line(env)
      line = "#{env["REQUEST_METHOD"]} #{env["SCRIPT_NAME"]}#{env['PATH_INFO']}"
      line << "?#{env["QUERY_STRING"]}" if env["QUERY_STRING"] and ! env["QUERY_STRING"].empty?
      line << " #{env["SERVER_PROTOCOL"]}"
      line
    end

    def extract_content_length(headers)
      value = headers[CONTENT_LENGTH] or return '-'
      value.to_s == '0' ? '-' : value
    end
  end
end