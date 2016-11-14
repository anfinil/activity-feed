module ActiveFeed
  module User
    class Proxy
      extend Forwardable
      def_delegators :@config, :backend

      attr_accessor :user, :config, :backend

      # @param user is either an array of models that respond
      # to +#to_af+, or a proc that yields a batch of users
      def initialize(user, config)
        self.user = user
        raise ObjectDoesNotImplementToAFError.new(user) unless serializable?(user)
        self.config  = config
        self.backend = config.backend
      end

      def publish!(event, sort)
        raise ObjectDoesNotImplementToAFError.new(event) unless serializable?(event)
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
        unread_count == 0
      end

      def unread_count
        backend.unread_count(user)
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
