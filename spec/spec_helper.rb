require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'activityfeed'

Dir['./spec/support/**/*.rb'].sort.each { |f| require(f)}
