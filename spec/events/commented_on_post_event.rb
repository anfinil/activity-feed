module MyApp
  module Events
    class CommentedOnPostEvent < AbstractEvent
      populates :follower_feed, :post_feed
    end
  end
end

