require 'activityfeed/backend/base'

module ActivityFeed
  module Backend
    # Single user's feed representation within the hash

    # Reference implementation of the simplest possible backend using 
    # in-process hash.
    class HashBackend < Base
      attr_accessor :h

      def initialize(*args)
        super(*args)
        self.h = {}
        self
      end
      
      def size
        h.size
      end
          
      def publish!(user, event, score)
        self[user].push(event, score)
      end
      
      def remove!(user, event)
        self[user].delete(event)
      end

      def reset_last_read!(user)
        self[user].read!
      end

      def paginate(user, page, per_page)
        self[user].paginate(page, per_page)
      end

      def unread_count(user)
        self[user].unread_count
      end

      def count(user)
        self[user].count
      end
      
      private
      
      def [](user)
        h[user.to_af] ||= ActivityFeed::User::Events.new(user)
      end
      
    end
  end
end
