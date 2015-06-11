require 'socket'
require 'uri'
require 'json'

module Rack

  class LogstashWriter

    # Initialize a new Rack adapter, logstash writer
    # @param [Hash] options
    # @option options [String] :url: required, udp and files schemes are also avaliable. no default values.
    # @option options [Hash] :request_headers,optional, parameters to add to the report from the request headers. default nil
    # @option options [Hash] :response_headers, optional, parameters to add to the report from the responce headers. default nil
    # @option options [Fixnum] :body_len, optional, include the first given chars from the body. default 1000
    # @option options [Array] :statuses, optional, send events to log stash only for those statuses. default [*(500..600)]
    def initialize app, options = {} #, statuses = [*(500..600)] , body_len = 1000 , url
      @app = app
      @options = validate defaults.merge options
      @options[:url]= URI(@options[:url])
    end

    # Call to the app cal and log if the returned status is in the array of return data.
    # @param [Hash] env : the enviroment
    def call env
      began = Time.now
      s, h, b = @app.call env
      b = BodyProxy.new(b) { log(env, s, h, began, b) } if @options[:statuses].include? s.to_i
      [s, h, b]
    end

    # Return the correct connection by the uri - udp/tcp/file
    private
    def defaults
         { request_headers: nil, response_headers: nil, statuses: [*(500..600)], body_len: 1000 }
      end

    def validate opt
      opt.tap { raise ":url is required" unless opt[:url] }
    end

    def device
      @device ||=
          case @options[:url].scheme
            when "file" then
              ::File.new(@options[:url].path,"a").tap {|f| f.sync=true}
            when "udp" then
              UDPSocket.new.tap { |s| s.connect @options[:url].host, @options[:url].port}
            when "tcp" then
              TCPSocket.new @options[:url].host,@options[:url].port
            else
              raise "Unknown scheme #{@options[:url].scheme}"
          end
    end

    # Log to the device the data
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
        data[:body] = body.join[0..@options[:body_len]]
      elsif body.is_a? BodyProxy
         (body.respond_to?(:body) ? data[:body] = body.body: data[:body] = body)
         data[:body] = data[:body].join[0..@options[:body_len]]
      end
      @options[:request_headers].each { |header, log_key| env_key = "HTTP_#{header.upcase.gsub('-', '_')}" ; data[log_key] = env[env_key] if env[env_key]} if !@options[:request_headers].nil?
      @options[:response_headers].each { |header, log_key| data[log_key] = response_headers[header] if response_headers[header] } if !@options[:response_headers].nil?

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