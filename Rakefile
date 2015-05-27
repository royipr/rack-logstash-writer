require "rake/testtask"

Rake::TestTask.new do |t|
  t.test_files = FileList['tests/unit/*_tests.rb']
end

task default: [:test]

task :test do
  "ruby tests/unit/*.rb"
end

