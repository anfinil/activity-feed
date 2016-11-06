module ActiveFeed
  module Backend
    class Base
      def publish!(user, event, score)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def remove!(event)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def paginate(user, page, per_page)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def unread_count(user)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def reset_last_read!(user)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def count(user)
        raise AbstractMethodCalledWithoutAnOveride, self
      end
    end
  end
end
