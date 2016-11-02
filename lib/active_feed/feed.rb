require 'forwardable'
module ActiveFeed
  class Feed
    FORWARDED_WRITE_METHODS = %i(publish remove reset aggregate reset_last_read)
    FORWARDED_READ_METHODS  = %i(paginate all filter unread_count)

    attr_accessor :config
    attr_accessor :backend
    attr_accessor :users

    def initialize(users: [], config: nil)
      self.users   = users
      self.config  = config
      self.backend = config.backend if config && config.respond_to?(:backend)
    end

    def method_missing(name, args, &block)
      super unless FORWARDED_READ_METHODS.include?(name) ||
        FORWARDED_WRITE_METHODS.include?(name)

      self.class.send(:define_method, name) do |args|
        backend.send(name, with_users(args), &block)
      end

      self.send(name, args, &block) if self.respond_to?(name)
    end

    private

    def with_users(args)
      args.merge!({ users: users  })
    end
  end
end
