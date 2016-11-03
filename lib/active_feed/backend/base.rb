module ActiveFeed
  module Backend
    class Base
      attr_accessor :users, :event

      class << self
        def for(*args)
          self.new(*args)
        end
      end

      # @param users is either an array of models that respond to +#to_af+, or a proc that yields a batch of users
      def initialize(users, event = nil)
        self.users = users
        self.event = event
      end

      def publish!(sort: 1)
      end

      # Removes all activity feed from the given set of users
      def wipe!
      end

      # Removes the current event (if available) from the given set of users
      def remove!
      end

      # This function walks via the feed, and
      def aggregate_similar!
      end

      def paginate(user:, page: 1, per_page:)
      end

      def unread_count(user:)
      end

      def mark_read(user:)
      end
    end
  end
end
