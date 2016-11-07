module ActiveFeed
  module Backend
    class Base
      def publish!
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def remove!
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def reset_last_read!
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def paginate
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def unread_count
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def count
        raise AbstractMethodCalledWithoutAnOveride, self
      end
    end
  end
end
