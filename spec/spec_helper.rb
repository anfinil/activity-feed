require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'activefeed'

Dir['./spec/support/**/*.rb'].sort.each { |f| require(f)}
