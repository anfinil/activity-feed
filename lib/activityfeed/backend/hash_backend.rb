require 'forwardable'
module ActivityFeed
  module Backend
    # Single user's feed representation within the hash
    extend Forwardable
    def_delegators :@__hash, :size, :keys, :values, :key, :key?, :clear, :each_key, :each_pair, :each_value
    # Reference implementation of the simplest possible backend using 
    # in-process hash.
    
    class HashBackend
      include ActivityFeed::Backend

      attr_accessor :__hash

      def initialize(config:)
        self.config = config
        self.__hash = ::Hash.new
        self
      end

      # Overridden methods
      def publish!(user, event, score)
        self[user].push(event, score)
      end

      def remove!(user, event)
        self[user].remove(event)
      end

      def reset_last_read!(user)
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
        keys.
          map { |u| u.gsub(/^#{config.namespace}/, '') }.
          map { |u| ActivityFeed::Serializable::Deserializer.klass_instance(u) }
      end
      

      private

      def [](user)
        __hash[::ActivityFeed::User::Events.hash_key(user)] ||= ::ActivityFeed::User::Events.new(user)
      end
    end
  end
end
