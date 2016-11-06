require 'hashie/mash'
require 'singleton'
require 'active_support/inflector'

module ActiveFeed

# A singleton instance of the +SuperConfiguration+ is created just once and
# then saved in +Configuration.config+ variable, as well is accessible via
# +SuperConfiguration.instance+ method.
# This class is not meant to be used by the user directly. Instead consumer of the library
# is directed to the helpers +#of+ within the +ActiveFeed+ module itself,
# or better yet — automatically generated constants.

  class SuperConfiguration < ::Hash
    include Singleton

    def of(key, *args)
      name       = key.to_sym
      self[name] ||= Configuration.new(name, *args)
      define_feed_constant(name)
      yield self[name] if block_given?
      self[name]
    end

    private

    def define_feed_constant(name)
      class_name = name.to_s.camelize.to_sym
      ActiveFeed.const_set(class_name, self[name]) unless ActiveFeed.const_defined?(class_name)
    end
  end
end
