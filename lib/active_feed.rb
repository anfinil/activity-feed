require 'forwardable'

require 'active_feed/version'
require 'active_feed/configuration'
require 'active_feed/feed'
require 'active_feed/collection'
require 'active_feed/backend'

module ActiveFeed

  class Error < StandardError
    def problem
      'suffered a general undertermined condition'
    end
    def initialize(object)
      super("Object of type #{object.class} value #{object} — #{problem}")
    end
  end

  class ObjectDoesNotImplementToAFError < ActiveFeed::Error
    def problem
      'object must implement #to_af instance method'
    end
  end

  class AbstractMethodCalledWithoutAnOveride < ActiveFeed::Error
    def problem
      'subclasses must be implementing these methods; you called an abstract top-level method.'
    end
  end

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
