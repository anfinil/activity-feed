module ActiveFeed
  module Backend
    class Base
      def push(user, event, score)
      end

      def clear
      end

      def remove(event)
      end

      def paginate(user, page, per_page)
      end

      def unseen_count(user)
      end

      def count(user)
      end

      def see(user)
      end
    end
  end
end
