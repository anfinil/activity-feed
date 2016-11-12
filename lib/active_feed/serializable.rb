require 'base62-rb'
require 'singleton'

module ActiveFeed
  module Serializable
    class Deserializer < ::Hash
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
          raise ArgumentError, "invalid serialized string [#{string}], can't find class identifier" unless klass_identifier
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
      end
    end

    TYPE_CHAR = { String => '&', Symbol => '!', Numeric => '%' }

    class << self
      def included(klass)
        klass.instance_eval do
          class << self
            attr_accessor :identifier_get_method, :identifier_set_method

            def identifier_method(method)
              self.identifier_get_method = method
              self.identifier_set_method = :"#{method}="
            end

            def __af_type
              @___af_type ||= self.name.gsub(/.*::/, '').split('').grep(/[A-Z]/).join.downcase
            end
          end
          ActiveFeed::Serializable::Deserializer[self.__af_type] = self
        end

        klass.identifier_method :id
      end
    end

    def __af_id=(val)
      type_char, value = val[0], val[1..-1]
      value_class      = TYPE_CHAR.invert[type_char]
      raise TypeError, "Unrecognized type character #{type_char}" unless value_class

      unpacked_id = if value_class == Numeric
                      Base62.decode(value)
                    elsif value_class == Symbol
                      value.to_sym
                    else
                      value
                    end

      # eg. call self.id = 2134 or self.username = :kigster
      send(self.class.identifier_set_method, unpacked_id)
    end

    def __af_id
      @__af_id ||= self.send(self.class.identifier_get_method)
      case @__af_id
        when Numeric
          TYPE_CHAR[Numeric] + Base62.encode(@__af_id)
        when *TYPE_CHAR.keys
          TYPE_CHAR[@__af_id.class] + @__af_id.to_s
        else
          raise TypeError, "Unsupported ID class #{@__af_id.class.name}"
      end
    end

    def to_af
      @__af ||= "#{self.class.__af_type}-#{self.__af_id}"
    end
  end
end
