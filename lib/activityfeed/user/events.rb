module ActivityFeed
  module User
    class Events
      Event = Struct.new(:event, :score)

      attr_accessor :user, :events, :last_read_at

      def initialize(user = nil)
        self.events ||= []
        self.user   = user
      end
      
      def self.hash_key(user)
        user.to_af
      end

      def push(event, score)
        events.unshift(Event.new(event, score))
        self
      end

      # stating with page 1
      # supports custom sorting via, etc.
      # paginate(1, 5) { |e1,e2| e1.created <=> e2.created } 
      def paginate(page = 1, per_page = config.per_page, &block)
        events
          .map(&:event)
          .sort{ |a, b| block_given? ? yield(a,b) : b.created <=> a.created }[((page - 1) * per_page) .. (page * per_page)]
      end

      def read!
        self.last_read_at = Time.now
      end

      def remove(event)
        events.reject! { |e| e.event == event }
      end

      def count(&block)
        block ? events.count { |event| block.call(event) } : events.size
      end

      def count_unread
        ue = self
        ue.last_read_at ? 
          ue.count do |e|
            e.score > ue.last_read_at
          end :
          count
      end
    end
  end
end
