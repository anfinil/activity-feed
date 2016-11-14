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
    
    def create_or_replace(name, *args, &block)
      self.configure.create_or_replace(name, *args, &block)
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
      self.instance_eval do 
        define_method(feed_name) { self.configure[feed_name] }
      end
    end
  end
end
