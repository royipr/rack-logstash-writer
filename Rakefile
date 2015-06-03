require "rake/testtask"

Rake::TestTask.new do |t|
  t.test_files = FileList['test/unit/*_tests.rb']
end

task default: [:test]

task :test do
  "ruby test/unit/*.rb"
end

task :install do
  system "gem build rack-logstash-writer.gemspec"
end

