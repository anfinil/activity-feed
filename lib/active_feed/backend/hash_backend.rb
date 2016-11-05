require 'active_feed/backend/base'

module ActiveFeed
  module Backend
    class HashBackend < Base
      attr_accessor :hash
      def initialize(*args)
        super(*args)
        self.hash = {}
      end

      def push(user, event, score)
        hash[user.to_af] ||= []
        hash[user.to_af] << [ event, score ]

      end


    end
  end
end
