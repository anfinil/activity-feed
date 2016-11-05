module ActiveFeed
  class Feed
    extend Forwardable
    def_delegators :@config, :backend

    attr_accessor :user, :config

    # @param user is either an array of models that respond
    # to +#to_af+, or a proc that yields a batch of users
    def initialize(user, config)
      self.user = user
      raise ObjectDoesNotImplementToAFError.new(user) unless user.respond_to?(:to_af)
      self.config = config
    end

    def publish!(event, sort)
      raise ObjectDoesNotImplementToAFError.new(event) unless event.respond_to?(:to_af)
    end

    # Removes the current event (if available) from the given set of users
    def remove!
    end

    def paginate(page: 1, per_page: config.per_page)
    end

    def unread_count
    end

    def reset_last_read
    end
  end
end
