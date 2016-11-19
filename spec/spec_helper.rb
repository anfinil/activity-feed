require 'simplecov'
SimpleCov.start

require 'activityfeed'

Dir['./spec/support/**/*.rb'].sort.each { |f| require(f)}
