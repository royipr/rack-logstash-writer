require 'socket'
require 'uri'
require 'json'

module Rack

  class LogstashWriter

    def initialize app, url, opts = {} , statuses_arr = [*(500..600)] , letters = 1000
      @app = app
      @uri = URI(url)
      @request_headers = opts[:request_headers] || {}
      @response_headers = opts[:response_headers] || {}
      @statuses_arr = statuses_arr
      @letters = letters
    end

    def call env
      began = Time.now
      s, h, b = @app.call env
      b = BodyProxy.new(b) { log(env, s, h, began, b) } if @statuses_arr.include? s.to_i
      [s, h, b]
    end

    private
    def device
      @device ||= begin
        case @uri.scheme
          when "file" then
            ::File.new(@uri.path,"a").tap {|f| f.sync=true}
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
          :method => env["REQUEST_METHOD"],
          :path => env["PATH_INFO"],
          :query_string => env["QUERY_STRING"],
          :status => status.to_i,
          :duration => (Time.now - began_at),
          :remote_addr => env['REMOTE_ADDR'],
          :request => request_line(env),
          :length => extract_content_length(response_headers),
          :"X-Forwarded-For" => response_headers['X-Forwarded-For']
      }

      if(body.is_a? String)
        data[:body] = body.join[0..@letters]
      elsif body.is_a? BodyProxy
        data[:body] = (body.respond_to?(:body) ? body.body: body).join[0..@letters]
      end
      @request_headers.each { |header, log_key| env_key = "HTTP_#{header.upcase.gsub('-', '_')}" ; data[log_key] = env[env_key] if env[env_key]}
      @response_headers.each { |header, log_key| data[log_key] = response_headers[header] if response_headers[header] }

      data[:error_msg] = env["sinatra.error"] if env.has_key?("sinatra.error")

      event = {'@fields' => data, '@tags' => ['request'], '@timestamp' => ::Time.now.utc, '@version' => 1}
      begin
        device.puts( event.to_json + '\n' )
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