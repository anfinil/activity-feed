module ActivityFeed
  module User
    class Proxy

      attr_accessor :user, :config, :backend

      # @param user is either an array create models that respond
      # to +#to_af+, or a proc that yields a batch of users
      def initialize(user, config)
        self.user = user
        raise InstanceMustBeSerializableError.new(user) unless serializable?(user)
        self.config  = config
        raise ArgumentError, "No backend defined in config #{config}" unless config.backend
        self.backend = config.backend
      end

      def publish!(event, sort)
        raise InstanceMustBeSerializableError.new(event) unless serializable?(event)
        backend.publish!(user, event, sort)
      end

      # Removes the current event (if available) from the given set of users
      def remove!(event)
        backend.remove!(user, event)
      end

      def paginate(page, per_page = config.per_page)
        backend.paginate(user, page, per_page)
      end

      def read?
        count_unread == 0
      end

      def count_unread
        backend.count_unread(user)
      end

      def count
        backend.count(user)
      end

      def reset_last_read!
        backend.reset_last_read!(user)
      end

      private
      def serializable?(obj)
        obj.respond_to?(:to_af) or (obj.is_a?(String) and obj.length < 100)
      end
    end
  end
end
