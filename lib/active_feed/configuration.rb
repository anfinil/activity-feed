require 'hashie/mash'
require 'singleton'
require 'active_support/inflector'
require_relative 'super_configuration'

module ActiveFeed

  # Instances of the +Configuration+ class define a single activity feed definition, with it's own
  # backend, name/namespace, and maximum size.
  #
  # Class methods #configure create a top-level Hash that maps each instance of +Configuration+
  # class onto a symbol – feed name, eg:
  #
  # ConfigurationHash
  class Configuration < Struct.new(:name, :namespace, :backend, :per_page, :max_size)

    class << self
      attr_accessor :config

      def configure
        self.config ||= SuperConfiguration.instance
        yield self.config if block_given?
        self.config
      end

      def clear!
        self.config.clear if self.config
      end
    end

    CALLBACK_EVENT_TYPES = %i(pop push remove)
    COLLECTION_TYPES     = [Proc, Array, Enumerable]

    # Instance methods
    def initialize(*args)
      super(*args)

      unless self.name and self.name.is_a?(Symbol)
        raise ArgumentError, 'Name of the feed is required and must be a symbol'
      end

      # set the defaults if not passed in
      self.per_page ||= 50
      self.max_size ||= 1000
      self.namespace||= name.to_s[0..1].to_sym

      # yield self for further customization
      yield self if block_given?
    end

    def for(users)
      (COLLECTION_TYPES.any? { |t| users.is_a?(t) }) ?
        ActiveFeed::Collection.new(users, self) :
        ActiveFeed::Feed.new(users, self)
    end

    def on(type, &block)
      return unless CALLBACK_EVENT_TYPES.include?(type)
      @on       ||= Hashie::Mash.new
      @on[type] = block if block
      @on[type]
    end


  end
end
