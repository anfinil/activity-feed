module ActivityFeed
  module Backend
    class RedisBackend
      include ActivityFeed::Backend

      attr_accessor :redis

      def initialize(redis:, config: nil)
        self.config = config if config
        self.redis = redis
        self
      end

      # Overridden methods
      def add(user_id, value, at)
        self[user_id].push(value, at)
      end

      def remove(user_id, value)
        self[user_id].remove(value)
      end

      def reset_unread(user_id)
        self[user_id].reset_unread
      end

      def paginate(user_id, page, per_page)
        self[user_id].paginate(page, per_page)
      end

      def count_unread(user_id)
        self[user_id].count_unread
      end

      def count(user_id)
        self[user_id].count
      end

      # Hash-specific methods
      def user_ids
        keys.
          map { |u| u.gsub(/^#{config.namespace}/, '') }.
          map { |u| ActivityFeed::Serializable::Deserializer.klass_instance(u) }
      end


      private

      def [](user_id)
        hash[::ActivityFeed::User::EventList.hash_key(user_id)] ||= ::ActivityFeed::User::EventList.new(user_id)
      end
    end
  end
end
