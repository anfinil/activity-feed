require 'forwardable'

require 'activityfeed/version'

require 'activityfeed/errors'

require 'activityfeed/config'
require 'activityfeed/feed'
require 'activityfeed/backend'
require 'activityfeed/serializable'

module ActivityFeed


  class << self
    # Returns the top-level Hash that contains all of the feeds,
    # @returns Config instance
    def configure(&block)
      Config.configure(&block)
    end

    # Creates the new feed configuration based on the name provided.
    # Raises an exception if the feed is already found.
    def feed(name, *args, &block)
      self.configure.feed(name, *args, &block)
    end

    def feeds
      ActivityFeed::Config.feeds
    end

    def feed_names
      ActivityFeed::Config.feed_names
    end

    def clear!
      ActivityFeed::Config.clear!
    end

    def register(feed_name)
      method_body = %Q{def self.#{feed_name}; self.feed(:#{feed_name}); end }
      ActivityFeed.module_eval method_body
    end

  end
end
