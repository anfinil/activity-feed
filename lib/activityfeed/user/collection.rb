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

      attr_reader :config
      attr_accessor :backend
      attr_accessor :users

      def initialize(users, config = nil)
        self.users   = users
        self.config  = config if config
      end

      def config=(config)
        raise ArgumentError, "No backend defined in config #{config}" unless config.backend
        @config      = config
        self.backend = config.backend
      end

      def each(&block)
        users.each(&block) if users.is_a?(Array)
      end

      def method_missing(name, *args, &block)
        super unless FORWARDED_METHODS.include?(name)

        # self.class.send(:define_method, name) do |*args|
        proxy_to_backend(name, *args, &block)
        # end
        # Now that we've defined that method, lets freaking run it.
        # self.send(name, *args, &block)
      end

      # TODO: implement concurrency using Celluloid
      def proxy_to_backend(name, *args, &block)
        case users
          when Array # could be a flat array, or a two-dimensional array
            users.each { |batch| proxy_batch_to_backend(args, batch, block, name)  }
          when Proc
            # Proc might yield either a single user, or multiple (ie. find_in_batches)
            # We support both variants.
            while batch = users.call
              break if batch.nil?
              proxy_batch_to_backend(args, batch, block, name)
            end
          else
            raise InstanceMustBeSerializableError.new(users) unless users.respond_to?(:to_af)
            backend.send(name, users, *args, &block)
        end
      end

      def proxy_batch_to_backend(args, batch, block, name)
        if batch.is_a?(Array)
          batch.each { |u| backend.send(name, u, *args, &block) }
        else
          backend.send(name, batch, *args, &block)
        end
      end

    end
  end
end
