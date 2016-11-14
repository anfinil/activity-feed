module ActivityFeed
  module Feed
    class Events
      attr_accessor :user, :events, :last_read_at

      def initialize(user = nil)
        self.events ||= []
        self.user   = user
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
        events.reject! { |h| h[:e] == event }
      end

      def count(&block)
        block ? events.grep { |event| block.call(event) }.size : events.size
      end

      def count_unread
        ue = self
        ue.count do |e|
          e.score > ue.last_read_at
        end
      end
    end
  end
end
