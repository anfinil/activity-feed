require 'activityfeed/serializable'

module ActivityFeed
  module User
    class Proxy

      attr_accessor :user, :backend
      attr_reader :config

      # @param user is either an array create models that respond
      # to +#to_af+, or a proc that yields a batch of users
      def initialize(user, config = nil)
        self.user = user
        unless serializable?(user)
          puts ActivityFeed::Serializable::Registry.instance.inspect
          raise InstanceMustBeSerializableError.new(user)
        end
        self.config = config if config
      end

      def config=(config)
        raise ArgumentError, "No backend defined in config #{config}" unless config.backend
        @config      = config
        self.backend = config.backend
      end

      #==================================================================
      
      def publish!(event, sort)
        raise InstanceMustBeSerializableError.new(event) unless serializable?(event)
        backend.publish!(user, event, sort)
      end

      def read!
        backend.read!(user)
      end

      # Removes the current event (if available) from the given set of users
      def remove!(event)
        backend.remove!(user, event)
      end

      def paginate(page, per_page = config.per_page)
        backend.paginate(user, page, per_page)
      end

      def count_unread
        backend.count_unread(user)
      end

      def count
        backend.count(user)
      end
      
      #==================================================================

      def read?
        count_unread == 0
      end

      private
      def serializable?(obj)
        obj.respond_to?(:to_af) && ActivityFeed::Serializable::Registry.supports?(obj)
      end
    end
  end
end
