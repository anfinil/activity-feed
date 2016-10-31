module ActiveFeed
  module Backend
    class Redis

      def publish(targets:, event:, sort: 1)
      end

      def clear(targets:)
      end

      def delete(targets:, event:)
      end

      def aggregate(targets:)
      end

      def paginate(target:,  page: 1, per_page:)
      end

      def unread_count(target:)
      end

      def mark_read(target:)
      end
    end
  end
end
