require 'hashie/mash'
require 'singleton'
require 'active_support/inflector'
require 'activityfeed/feed/configuration'

module ActivityFeed

# A singleton instance of the +SuperConfiguration+ is created just once and
# then saved in +Configuration.config+ variable, as well is accessible via
# +SuperConfiguration.instance+ method.
# This class is not meant to be used by the user directly. Instead consumer of the library
# is directed to the helpers +#of+ within the +ActivityFeed+ module itself,
# or better yet — automatically generated constants.

  class Config < ::Hash
    include Singleton

    class << self
      def configure
        block_given? ? yield(instance) : instance
      end

      def clear!
        instance.clear
      end

      def feed_names
        instance.keys
      end

      def feeds
        instance.values
      end

      def [](value)
        instance[value]
      end
    end

    def create(key, *args, &block)
      __feed(key, false, *args, &block)
    end

    def feed(key, *args, &block)
      __feed(key, true, *args, &block)
    end

    private

    def __feed(key, feed, *args, &block)
      name = key.to_sym

      if self[name] && feed
        block.call(self[name]) if block

      elsif self[name]
        raise ArgumentError, "Feed named #{name} already exists!"

      else
        self[name] = Feed::Configuration.new(name, *args, &block)
        define_feed_constant(name)
        define_method_accessor(name)
      end

      self[name]
    end

    def define_feed_constant(name)
      class_name = name.to_s.camelize.to_sym
      ActivityFeed.const_set(class_name, self.class.instance[name]) unless ActivityFeed.const_defined?(class_name)
    end

    def define_method_accessor(name)
      unless ActivityFeed.respond_to?(name)
        ActivityFeed.register(name)
      end
    end
  end
end
