require 'active_feed/backend/base'

module ActiveFeed
  module Backend
    # Single user's feed representation within the hash
    class UserFeed
      attr_accessor :user, :events, :last_read_at
      def initialize(user = nil)
        self.events ||= []
        self.user = user
      end
      
      def push(event)
        # TODO: serialize
        events.unshift(event)
        self
      end
    end
    
    # Reference implementation of the simplest possible backend using 
    # in-process hash.
    class HashBackend < Base
      attr_accessor :h

      def initialize(*args)
        super(*args)
        self.h = {}
      end
      
      def publish!(user, event, score)
        h[user] ||= UserFeed.new(user) 
        h[user].push(event)
      end

      def remove!(user, event)
        h[user].delete(event) if h[user].is_a?(Array)
      end

      def reset_last_read!(*args)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def paginate(user, page, per_page)
        
      end

      def unread_count(*args)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def count(*args)
        raise AbstractMethodCalledWithoutAnOveride, self
      end

      def push(user, event, score)
        hash[user.to_af] ||= []
        hash[user.to_af] << [event, score]

      end


    end
  end
end
