# myapp.rb
require 'sinatra'

get '/' do
  'Hello world!'
end

get '/hello/:name' do |n|
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params['name'] is 'foo' or 'bar'
  # n stores params['name']
  "Hello #{n}!"
end

get '/goodbye/:name' do |n|
  "Goodbye #{n}!"
  [555, {"Content-Type" => "application/json"}, ['{\"keyword_finder\":\"http://localhost:11120\",\"service_namev:\"abi-mgmt\"}'] ]
  # [{"\"db_host\":\"localhost\",\"env\":\"development\",\"redis\":\"redis://localhost:6379\",\"keyword_finder\":\"http://localhost:11120\",\"service_name\":\"abi-mgmt\"}\""}
end

get '/error/:name' do |n|
  "Error #{n}!"
  1/0
end

