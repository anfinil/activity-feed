module ActivityFeed
  module Backend
    REQUIRED_METHODS = %i(add remove reset_unread paginate unread_count count)

    def self.included(klass)
      klass.class_eval do
        REQUIRED_METHODS.each do |method_name|
          define_method(method_name) do |*|
            raise AbstractMethodCalledError, self
          end
        end
      end
      klass.instance_eval do 
        attr_accessor :config
      end
    end
  end
end

require 'activityfeed/backend/redis_backend'
require 'activityfeed/backend/hash_backend'
