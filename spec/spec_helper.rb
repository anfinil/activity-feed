require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'active_feed'

Dir['./spec/support/**/*.rb'].sort.each { |f| require(f)}
