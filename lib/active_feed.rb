require 'forwardable'

require 'active_feed/version'
require 'active_feed/configuration'
require 'active_feed/feed'
require 'active_feed/collection'
require 'active_feed/backend'

module ActiveFeed
  class Error < StandardError; end

  class << self
    def configure(&block)
      ActiveFeed::Configuration.send(:configure, &block)
    end
    def of(name, *args, &block)
      self.configure.of(name, *args, &block)
    end
    def feed_names
      ActiveFeed::Configuration.config.keys if ActiveFeed::Configuration.config
    end
    def clear!
      ActiveFeed::Configuration.clear!
    end
  end
end
