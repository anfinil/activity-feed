require 'active_feed/version'

module ActiveFeed
  class Error < StandardError; end

  class << self
    def configure(&block)
      ActiveFeed::Configuration.send(:configure, &block)
    end
    def of(name, &block)
      self.configure.of(name, &block)
    end
  end
end

require 'active_feed/configuration'
require 'active_feed/feed'
require 'active_feed/backend'
