require 'base62-rb'
require 'singleton'

module ActivityFeed
  module Serializable
    class Registry < ::Hash
      include Singleton
      class << self
        def [](value)
          instance[value]
        end

        def []=(identifier, klass)
          existing = instance[identifier]
          raise ArgumentError,
                "identifier #{identifier} is already assigned to #{existing.name}" if existing && existing != klass
          instance[identifier.to_sym] = klass
        end

        def klass(string)
          klass_identifier = string.split(/-/)[0]
          raise ArgumentError,
                "invalid serialized string [#{string}], can't find class identifier" unless klass_identifier
          instance[klass_identifier.to_sym]
        end

        def klass_instance(string)
          type       = klass(string)
          identifier = string.split(/-/)[1]
          raise ArgumentError, "invalid serialized string [#{string}" unless identifier

          created_instance         = type.new
          created_instance.__af_id = identifier
          created_instance
        end

        # We support an object, if its class is Serializable and is already included in the Registry.
        def supports?(another_object)
          another_object.class.ancestors.include?(ActivityFeed::Serializable) &&
            instance[another_object.class.__af_type.to_sym]
        end
      end
    end
  end
end
