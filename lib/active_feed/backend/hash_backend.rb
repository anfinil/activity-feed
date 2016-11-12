require 'active_feed/backend/base'

module ActiveFeed
  module Backend
    # Single user's feed representation within the hash
    UserEvent = Struct.new(:event, :score)
    
    class UserFeed
      attr_accessor :user, :events, :last_read_at
      def initialize(user = nil)
        self.events ||= []
        self.user = user
      end
      
      def push(event, score)
        events.unshift(UserEvent.new(Marshal.dump(event), score))
        self
      end
      
      def paginate(page, per_page)
        events[(page - 1) * per_page, (page * per_page)]
      end
      
      def read!
        self.last_read_at = Time.now
      end
      
      def delete(event)
        events.reject!{ |h| h[:e] == event } 
      end
      
      def count(&block)
        block ? events.grep{ |event| block.call(event) }.size : events.size
      end
      
      def count_unread
        ue = self
        ue.count do |e| 
          e.score > ue.last_read_at
        end
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
        h[user.to_af] ||= UserFeed.new(user)
      end
      
    end
  end
end
