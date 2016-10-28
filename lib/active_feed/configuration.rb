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

    attr_accessor :backend
  end
end
