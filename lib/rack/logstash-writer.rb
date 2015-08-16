require 'socket'
require 'uri'
require 'json'
require 'socket'

module Rack
  class LogstashWriter
    # Initialize a new Rack adapter, logstash writer
    # @param [Hash] options
    # @option options [String] :url: required, udp and files schemes are also avaliable. no default values.
    # @option options [Hash] :request_headers,optional, parameters to add to the report from the request headers. default nil
    # @option options [Hash] :response_headers, optional, parameters to add to the report from the responce headers. default nil
    # @option options [Fixnum] :body_len, optional, include the first given chars from the body. default 1000
    # @option options [Array] :statuses, optional, send events to log stash only for those statuses. default [*(500..600)]
    # @option options [Proc] :proc, optional, the function will call the proc with the env and call
    def initialize app, options = {} #, statuses = [*(500..600)] , body_len = 1000 , url
      @app = app
      @options = validate defaults.merge options
      @options[:url]= URI(@options[:url])
      @proc = @options[:proc]
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
          :host => Socket.gethostname,
          :status => status.to_i,
          :duration => (Time.now - began_at),
          :remote_addr => env['REMOTE_ADDR'],
          :request => request_line(env),
          :"X-Forwarded-For" => response_headers['X-Forwarded-For']

      }

      # Added calling for the proc and merge the data if it exists

      if @proc
        begin
          new_hash = @proc.call(env)
          data = data.merge new_hash if new_hash.class == Hash
        rescue Exception => e
          STDERR.puts "Exception in your proc : #{e.message}."
        end
      end

      # This just works for all body types (magic?)... see http://www.rubydoc.info/github/rack/rack/Rack/BodyProxy
      body.each{|x| data[:body] = x[0..@options[:body_len]] }
      @options[:request_headers].each { |header, log_key| env_key = "HTTP_#{header.upcase.gsub('-', '_')}" ; data[log_key] = env[env_key] if env[env_key]} if !@options[:request_headers].nil?
      @options[:response_headers].each { |header, log_key| data[log_key] = response_headers[header] if response_headers[header] } if !@options[:response_headers].nil?

      data[:error_msg] = env["sinatra.error"] if env.has_key?("sinatra.error")



      @options[:body_regex].each { |k,v| data[k] = data[:body].to_s.match(/#{v}/).captures[0].gsub("\\","").gsub("\"","") rescue data[k]= "" } if !@options[:body_regex].nil?

      severity = "DEBUG"
      case status
        when 300..399 then severity = "WARN"
        when 400..599 then severity = "ERROR"
      end
      event = {:severity => severity}.merge data
      # TODO to include this lines
      begin
        device.puts( event.to_json )
      rescue Exception => e
        STDERR.puts "Error : Failed to write log to : #{@options[:url]}, #{e.message}."
        @device = nil
      end
    end

    def request_line env
      line = "#{env["REQUEST_METHOD"]} #{env["SCRIPT_NAME"]}#{env['PATH_INFO']}"
      line << "?#{env["QUERY_STRING"]}" if env["QUERY_STRING"] and ! env["QUERY_STRING"].empty?
      line << " #{env["SERVER_PROTOCOL"]}"
      line
    end

  end
end
