require 'ventable' rescue nil

require 'active_support'
require 'activityfeed'

module ActivityFeed
  # Users of this library are supposed to include this module in their own
  # event classes, for example:
  #```ruby
  # class UserCommentedEvent 
  #   include ActivityFeed::Event
  #   publishes_to :followers, :own_activities
  # end
  #```
  module Event

    def self.included(klass)
      klass.instance_eval do

        include Ventable::Event if Kernel.const_defined?(:Ventable)
        
        include ActivityFeed::Serializable

        class << self
          attr_accessor :feeds

          def publishes_to(*feeds)
            self.feeds ||= []
            self.feeds << feeds if feeds
            self.feeds.flatten!
          end

          def event_name
            self.name.sub(/::/, '').underscore.chomp('_event')
          end
        end

        self.publishes_to [] # default is nothing
      end

      klass.class_eval do
        attr_accessor :actor, :target, :owner, :created

        def initialize(actor:, target:, owner: nil, created: Time.now.to_f)
          self.actor   = actor
          self.target  = target
          self.owner   = owner
          self.created = created

          unless self.owner
            self.owner ||= target.user if target.respond_to?(:user)
            self.owner ||= target if target.class.name =~ /user$/i
          end
        end
        
        def audience
          raise AbstractMethodCalledError, 'Please override #audience in the event classes'
        end

        def fire!
          super
          self.class.feeds.each do |feed|
            ActivityFeed.feed(feed).for(audience).publish!(self, self.created)
          end
        end
      end
    end

  end
end
