require 'hashie/mash'
require 'singleton'

module ActiveFeed

  # Instances of the +Configuration+ class define a single activity feed definition, with it's own
  # backend, name/namespace, and maximum size.
  #
  # Class methods #configure create a top-level Hash that maps each instance of +Configuration+
  # class onto a symbol – feed name, eg:
  #
  # ConfigurationHash
  class Configuration < Struct.new(:name, :namespace, :backend, :per_page, :max_size)

    CALLBACK_EVENT_TYPES = %i(pop push remove)
    FeedCallback         = Struct.new(:proc)

    # Instance methods
    def initialize(*args, &block)
      super(*args)

      unless self.name and self.name.is_a?(Symbol)
        raise ArgumentError, 'Name of the feed is required and must be a symbol'
      end

      # set the defaults if not passed in
      self.per_page ||= 50
      self.max_size ||= 1000
      self.namespace  = name.to_s[0..1].to_sym

      # yield self for further customization
      yield self if block_given?
    end

    def on(type, &block)
      return unless CALLBACK_EVENT_TYPES.include?(type)
      @on       ||= Hashie::Mash.new
      @on[type] = block if block
      @on[type]
    end

    # Class methods

    class << self
      attr_accessor :config

      def configure
        self.config ||= ConfigurationHash.instance
        yield self.config if block_given?
        self.config
      end
    end
  end

  # A singleton instance of the +ConfigurationHash+ is created just once and
  # then saved in +ActiveFeed::Configuration.config+ variable, as well is accessible via
  # +ConfigurationHash.instance+ method.
  # This class is not meant to be used by the user directly. Instead consumer of the library
  # is directed to the helpers +#of+ within the +ActiveFeed+ module itself.

  class ConfigurationHash < ::Hash
    include Singleton
    def of(key)
      name       = key.to_sym
      self[name] ||= Configuration.new(name)
      yield self[name] if block_given?
      self[name]
    end
  end

end
