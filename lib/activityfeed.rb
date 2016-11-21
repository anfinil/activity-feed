require 'forwardable'

module ActivityFeed

  @registry = {}

  def self.registry
    @registry
  end

  def self.define(name)
    name   = name.to_sym
    config = self.registry[name] ? self.registry[name] : Configuration.new(name)
    yield config if block_given?
    self.registry[name] = config
    self.create_feed_method(name)
    config
  end

  def self.[](name)
    self.registry[name]
  end

  def self.feed_names
    self.registry.keys
  end

  def self.clear!
    self.registry.clear
  end

  def self.create_feed_method(feed_name)
    method_body = %Q{def self.#{feed_name}; self[(:#{feed_name})]; end }
    ActivityFeed.module_eval method_body
  end

end
require 'activityfeed/version'
require 'activityfeed/errors'
require 'activityfeed/configuration'
require 'activityfeed/feed'
require 'activityfeed/backend'
require 'activityfeed/serializable'

