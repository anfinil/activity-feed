module ActivityFeed
  module Backend
    class RedisBackend
      include ActivityFeed::Backend
      attr_accessor :redis

      def initialize(config: nil, redis:)
        self.config = config if config
        self.redis  = redis
        self
      end

      # Overridden methods
      def publish!(user, event, score)
        self[user].push(event, score)
      end

      def remove!(user, event)
        self[user].remove(event)
      end

      def read!(user)
        self[user].read!
      end

      def paginate(user, page, per_page)
        self[user].paginate(page, per_page)
      end

      def count_unread(user)
        self[user].count_unread
      end

      def count(user)
        self[user].count
      end

      # Hash-specific methods
      def users
        keys.map { |u| ActivityFeed::Serializable::Registry.klass_instance(u) }
      end

      private

      def [](user)
        hash[::ActivityFeed::User::Activities.to_key(user)] ||= ::ActivityFeed::User::Activities.new(user)
      end
    end
  end
end
