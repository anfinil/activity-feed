module ActiveFeed
  module Backend
    class AbstractBackend
      def publish(users:, event:, sort: 1)
      end

      def clear(users:)
      end

      def delete(users:, event:)
      end

      def aggregate(users:)
      end

      def paginate(users:, page: 1, per_page:)
      end

      def unread_count(users:)
      end

      def mark_read(users:)
      end
    end
  end
end
