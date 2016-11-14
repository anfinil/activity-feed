module ActivityFeed
  module Backend
    class Base
      def publish!(*args)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def remove!(*args)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def reset_last_read!(*args)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def paginate(*args)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def unread_count(*args)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def count(*args)
        raise AbstractMethodCalledWithoutAnOveride, self
      end
    end
  end
end
