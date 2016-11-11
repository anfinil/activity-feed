require 'ventable'
require 'active_support'

module MyApp
  module Events
    class AbstractEvent
      class << self
        def event_name
          self.name.sub(/::/, '').underscore.chomp('_event')
        end

        def load(string)

        end
      end

      def self.inherited(klass)
        klass.instance_eval do
          include Ventable::Event
          class << self
            attr_accessor :__feeds
            def populates(*feeds)
              self.__feeds ||= []
              self.__feeds << feeds
              self.__feeds.flatten!
            end
          end

        end
      end

      attr_accessor :actor, :target, :owner

      def initialize(actor:, target:)
        self.actor  = actor
        self.target = target
      end

      def dump
      end
    end
  end
end

require_relative 'commented_on_post_event'
require_relative 'followed_user_event'
