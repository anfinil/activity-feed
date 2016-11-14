module MyApp
  module Events
    class FollowedUserEvent < AbstractEvent
      populates :follower_feed
    end
  end
end

