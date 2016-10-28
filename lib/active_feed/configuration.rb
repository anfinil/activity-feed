# This class encapsulates application configuration, and offers
# a class method +#configure+ for defining configuration in a
# block.
# #
# == Example
#
#```ruby
#     ActiveFeed.config do |c|
#       c.backend = ActiveFeed::Backend::Redis.new(redis: Redis.new)
#     end
#```
module ActiveFeed
  class Configuration
    class << self
      attr_accessor :config

      def configure
        self.config ||= Configuration.new
        yield config if block_given?
        config
      end

      def property(name)
        self.config.send(name)
      end
    end

    # Set to a backend able to fulfill the API contract with the
    # ActiveFeed gem.
    attr_accessor :backend

    # Items per page to return
    attr_accessor :per_page

    # Maximum number of items stored in the feed
    attr_accessor :feed_length

    def initialize
      self.per_page = 50
      self.feed_length = 1000
    end

  end
end
