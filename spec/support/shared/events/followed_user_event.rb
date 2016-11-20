require 'activityfeed/event'

module MyApp
  module Events
    class FollowedUserEvent

      include ActivityFeed::Event

      publishes_to :follower_feed
      
      def audience
        actor.followers
      end
    end
  end
end

