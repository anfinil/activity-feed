require 'forwardable'
module ActiveFeed
  class Reader
    extend Forwardable
    def_delegators :@backend, :mark_as_read

    attr_accessor :configuration
    attr_accessor :backend

    # Whose feed we are reading here.
    attr_accessor :target

    def initialize(target:, configuration: nil)
      self.target        = target
      self.configuration = configuration
      self.backend       = configuration.backend if configuration
    end

    # Paginated access to feed items.
    def paginate(args = {})
      backend.paginate(with_target(args))
    end

    # Number of items in the feed when type.nil?
    # Other events for type are: :unread, :read which return the counts of read/unread items.
    def count(args = {})
      unless type.nil? or %i(read unread).include(type)
        raise ArgumentError, "Type can only be nil, :read and :unread, got #{type.to_s}"
      end
      backend.count(with_target(args))
    end

    private

    def with_target(args)
      args.merge!({ target: target })
    end
  end
end
