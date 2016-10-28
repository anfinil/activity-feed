require 'active_feed/version'

module ActiveFeed
  class Error < StandardError; end
  class AbstractMethodCalledError < ActiveFeed::Error; end

  class << self
    def config(property = nil, &block)
      configuration = ActiveFeed::Configuration.send(:configure, &block)
      property.nil? ? configuration : configuration.send(property)
    end
  end
end

require 'active_feed/configuration'
