require 'base62-rb'
require 'activityfeed/serializable/registry'
require 'activityfeed/serializable/serializer'

module ActivityFeed
  module Serializable
    class << self
      def included(klass)
        
        klass.include(ActivityFeed::Serializable::Serializer::InstanceMethods)
        klass.extend(ActivityFeed::Serializable::Serializer::ClassMethods)
        
        # Register this class with the deserializer
        ::ActivityFeed::Serializable::Registry[klass.__af_type] = klass

        # Default identifier to :id
        klass.identifier_method :id
      end
    end

    TYPE_CHAR = { String => '&', Symbol => '!', Numeric => '%', Marshal => '#' }
  end
end
