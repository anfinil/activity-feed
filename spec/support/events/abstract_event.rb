require 'ventable'
require 'active_support'
require 'activityfeed'

module MyApp
  module Events
    class AbstractEvent
      class << self
        def event_name
          self.name.sub(/::/, '').underscore.chomp('_event')
        end
      end

      def self.inherited(klass)
        klass.instance_eval do
          include Ventable::Event
          include ActivityFeed::Serializable
          class << self
            attr_accessor :activity_feeds
            def publishes_to(*feeds)
              self.activity_feeds ||= []
              self.activity_feeds << feeds if feeds
              self.activity_feeds.flatten!
            end
          end
          
          self.publishes_to []
        end
        klass.class_eval do
          def fire!
            super
            self.class.activity_feeds.each do |feed|
              ActivityFeed.find_or_create(feed).for(actor).publish!(self, self.created)
            end
          end
        end
      end

      attr_accessor :actor, :target, :owner, :created

      def initialize(actor:, target:)
        self.actor   = actor
        self.target  = target
        self.created = Time.now
      end
    end
  end
end

require_relative 'commented_on_post_event'
require_relative 'followed_user_event'
