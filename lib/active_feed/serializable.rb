require 'base62-rb'
require 'active_feed/serializable/deserializer'

module ActiveFeed
  module Serializable

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
          ::ActiveFeed::Serializable::Deserializer[self.__af_type] = self
        end

        klass.identifier_method :id
      end
    end

    TYPE_CHAR = { String => '&', Symbol => '!', Numeric => '%' }

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
