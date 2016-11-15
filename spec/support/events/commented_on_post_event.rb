module MyApp
  module Events
    class CommentedOnPostEvent < AbstractEvent
      publishes_to :follower_feed
    end
  end
end

