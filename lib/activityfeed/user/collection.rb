require 'forwardable'
module ActivityFeed
  module User
    # This class decorates the +Feed+ class with operations performed across
    # multiple users. It then forwards it to the Feed class for each user.
    class Collection
      include Enumerable

      FORWARDED_WRITE_METHODS = %i(publish! remove! reset_last_read!)
      FORWARDED_READ_METHODS  = %i(paginate unread_count count)
      FORWARDED_METHODS       = FORWARDED_READ_METHODS + FORWARDED_WRITE_METHODS

      attr_accessor :config
      attr_accessor :backend
      attr_accessor :users

      def initialize(users, config)
        self.users   = users
        self.config  = config
        self.backend = config.backend
      end

      def each(&block)
        users.each(&block) if users.is_a?(Array)
      end

      def method_missing(name, *args, &block)
        super unless FORWARDED_METHODS.include?(name)

        self.class.send(:define_method, name) do |*args|
          proxy_to_backend(name, *args, &block)
        end
        # Now that we've defined that method, lets freaking run it.
        self.send(name, *args, &block)
      end

      # TODO: implement concurrency using Celluloid
      def proxy_to_backend(name, *args, &block)
        case users
          when Array
            users.each { |u| backend.send(name, u, *args, &block) }
          when Proc
            # Proc might yield either a single user, or multiple (ie. find_in_batches)
            # We support both variants.
            while batch_of_users = users.call
              break if batch_of_users.nil?
              batch_of_users.is_a?(Array) ?
                batch_of_users.each { |u| backend.send(name, u, *args, &block) } :
                backend.send(name, batch_of_users, *args, &block) # users is a single object
            end
          else
            raise ObjectDoesNotImplementToAFError.new(users) unless users.respond_to?(:to_af)
            backend.send(name, users, *args, &block)
        end
      end

    end
  end
end
