require 'active_feed/backend/base'
require 'active_feed/serializer'

module ActiveFeed
  module Backend
    # Single user's feed representation within the hash
    class UserFeed
      include ActiveFeed::Serializer
      
      attr_accessor :user, :events, :last_read_at
      def initialize(user = nil)
        self.events ||= []
        self.user = user
      end
      
      def push(event)
        events.unshift(sz(event))
        self
      end
    end
    
    # Reference implementation of the simplest possible backend using 
    # in-process hash.
    class HashBackend < Base
      include ActiveFeed::Serializer
      
      attr_accessor :h

      def initialize(*args)
        super(*args)
        self.h = {}
      end
      
      def publish!(user, event, score)
        h[sz(user)] ||= UserFeed.new(user) 
        h[sz(user)].push(event)
      end

      def remove!(user, event)
        h[sz(user)].delete(sz(event)) if h[sz(user)].is_a?(Array)
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
