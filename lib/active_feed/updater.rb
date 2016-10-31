require 'forwardable'

module ActiveFeed
  class Updater
    extend Forwardable
    DELEGATES = %i(publish remove reset aggregate reset_last_read)

    attr_accessor :configuration
    attr_accessor :backend
    attr_accessor :targets

    def initialize(targets: [], configuration:)
      self.targets       = targets
      self.configuration = configuration
      self.backend       = configuration.backend if configuration
    end

    def method_missing(name, args, &block)
      super unless DELEGATES.include? name
      backend.send(name, with_targets(args), &block)
    end

    private

    def with_targets(args)
      args.merge!({ targets: targets })
    end
  end
end
