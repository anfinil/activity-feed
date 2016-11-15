module MyApp
  module Events
    class FollowedUserEvent < AbstractEvent
      publishes_to :follower_feed
    end
  end
end

