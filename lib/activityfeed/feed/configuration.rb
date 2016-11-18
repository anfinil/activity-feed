require 'hashie/mash'
require 'singleton'
require 'active_support/inflector'
require 'activityfeed/config'

module ActivityFeed
  module Feed

    # Instances of the +Configuration+ class define a single activity
    # feed definition, with it's own backend, name/namespace, and maximum size.
    #
    # Class methods #configure create a top-level Hash that maps each 
    # instance of +Configuration+ class onto a symbol – feed name, eg:

    class Configuration < Struct.new(:name, :namespace, :backend, :per_page, :max_size)

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
        self
      end
      
      def configure
        yield self if
        self
      end

      def for(users)
        feed_wrapper = (COLLECTION_TYPES.any? { |t| users.is_a?(t) }) ?
          ActivityFeed::User::Collection.new(users) :
          ActivityFeed::User::Proxy.new(users)
        feed_wrapper.config = self if feed_wrapper.respond_to?(:config=)
        feed_wrapper
      end
      
      def equal?(other)
        other.class == self.class && 
          self.class.members.all?{ |m| self.send(m).equal?(other.send(m))} 
      end

    end
  end
end
