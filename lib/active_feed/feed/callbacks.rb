module ActiveFeed
  module Feed
    module Callbacks
      EVENTS = %i(pop push remove)

      attr_accessor :on

      def on(type, &block)
        raise ArgumentError.new("Invalid event type #{type}") unless EVENTS.include?(type)

        @on ||= Hashie::Mash.new

        @on[type] = block if block
        @on[type]
      end
    end
  end
end
