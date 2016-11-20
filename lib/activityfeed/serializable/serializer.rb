require 'base62-rb'
require 'singleton'

module ActivityFeed
  module Serializable
    module Serializer

      module ClassMethods
        attr_accessor :identifier_get_method, :identifier_set_method

        def identifier_method(method)
          self.identifier_get_method = method
          self.identifier_set_method = :"#{method}="
        end

        # Take only capital letters from the class name, eg User => 'U', 'UserProfile' => 'UP'
        def af_type_id
          @af_type_id ||= self.name.gsub(/.*::/, '').split('').grep(/[A-Z]/).join.downcase
        end
      end

      module InstanceMethods
        def to_af
          @__af ||= "#{self.class.af_type_id}-#{self.__af_id}"
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

          if self.respond_to?(self.class.identifier_set_method)
            # eg. call self.id = 2134 or self.username = :kigster
            send(self.class.identifier_set_method, unpacked_id)
            send(self.class.af_load) if self.class.respond_to?(:af_load)
          elsif value_class == Marshal
            Marshal.load(value)
          end
          
        end

        def __af_id
          if self.respond_to?(self.class.identifier_get_method)
            identifier ||= self.send(self.class.identifier_get_method)
            @__af_id   ||= case identifier
                             when Numeric
                               TYPE_CHAR[Numeric] + Base62.encode(identifier)
                             when *TYPE_CHAR.keys
                               TYPE_CHAR[identifier.class] + identifier.to_s
                             else
                               raise TypeError, "Unsupported ID class #{identifier.class.name}"
                           end
          else
            @__af_id ||= TYPE_CHAR[Marshal] + Marshal.dump(self)
          end

        end

      end
    end
  end
end
