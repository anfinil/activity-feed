require 'active_support/inflector'

module ActivityFeed

  # Instances of the +Configuration+ class define a single activity
  # feed definition, with it's own backend, name/namespace, and maximum size.
  #
  # Class methods #configure create a top-level Hash that maps each
  # instance of +Configuration+ class onto a symbol – feed name, eg:

  class Configuration
    attr_accessor :name, :backend, :per_page, :max_size

    COLLECTION_TYPES = [Proc, Array, Enumerable]

    # Instance methods
    def initialize(name)
      self.name     = name.is_a?(Symbol) ? name : name.to_sym
      # set the defaults if not passed in
      self.per_page ||= 50
      self.max_size ||= 1000

      # yield self for further customization
      yield self if block_given?
      self
    end

    def configure
      yield self if block_given?
      self
    end

    def for(users)
      feed_wrapper        = (COLLECTION_TYPES.any? { |t| users.is_a?(t) }) ?
        ActivityFeed::User::Collection.new(users) :
        ActivityFeed::User::Proxy.new(users)
      feed_wrapper.config = self if feed_wrapper.respond_to?(:config=)
      feed_wrapper
    end

    def equal?(other)
      other.class == self.class &&
        %i(per_page backend max_size name).all? { |m| self.send(m).equal?(other.send(m)) }
    end
  end
end
