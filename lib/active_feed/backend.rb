module ActiveFeed
  module Backend
  end
end

require 'active_feed/backend/abstract_backend'
require 'active_feed/backend/redis_backend'
require 'active_feed/backend/hash_backend'
