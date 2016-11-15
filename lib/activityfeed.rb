require 'forwardable'

require 'activityfeed/version'

require 'activityfeed/errors'

require 'activityfeed/config'
require 'activityfeed/feed'
require 'activityfeed/backend'
require 'activityfeed/serializable'

module ActivityFeed


  class << self
    def configure(&block)
      ActivityFeed::Config.configure(&block)
    end

    def create(name, *args, &block)
      self.configure.create(name, *args, &block)
    end

    alias_method :of, :create

    def find_or_create(name, *args, &block)
      self.configure.find_or_create(name, *args, &block)
    end

    def feed(name)
      ActivityFeed::Config[name.to_sym]
    end

    def feed_names
      ActivityFeed::Config.feeds
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
