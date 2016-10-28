module ActiveFeed
  class Reader

    attr_accessor :user
    def initialize(user:)
      self.user = user
    end

    # Paginated access to feed items.
    def paginate(page: 1, per_page: 20)
      raise AbstractMethodCalledError, 'backend not defined'
    end

    # Nmber of items in the feed when type.nil?
    # Other events for type are: :unread, :read
    # which return the counts of read/unread items.
    def count(type: nil)
      unless type.nil? or %i(read unread).include(type)
        raise ArgumentError, "Type can only be nil, :read and :unread, got #{type.to_s}"
      end
      raise AbstractMethodCalledError, 'backend not defined'

    end

    # Mark user's feed as 'read'
    def read!
      raise AbstractMethodCalledError, 'backend not defined'
    end
  end
end
