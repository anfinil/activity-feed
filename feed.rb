ActiveFeed.configure do |config|
  config.for(:news_feed) do |news_feed|
    news_feed.backend           = ActiveFeed::Backend::Redis.new(
      redis: -> { ::Redis.new(host: '127.0.0.1') }
    )
    # how many items can be in the feed
    news_feed.max_size          = 1000
    news_feed.namespace         = 'nf' # User's news feed
    news_feed.default_page_size = 20
    news_feed.on_push           = ->(user, new_event) {
      Logger.info "added an event #{new_event} from the feed of #{user}"
    }
    news_feed.on_pop            = ->(user, old_event) {
      Logger.info "discarding event #{old_event} from the feed of #{user}"
    }
    news_feed.on_delete         = ->(user, deleted_event) {
      Logger.info "deleting an event #{deleted_event} from the feed of #{user}"
    }
  end
