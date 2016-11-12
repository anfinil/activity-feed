require 'base62-rb'

module ActiveFeed
  module Serializable

    class << self
      def included(klass)
        klass.instance_eval do
          class << self
            attr_accessor :identifier_method

            def __af_version
              @__af_version ||= '1'
            end

            def __af_type
              @___af_type ||= self.name.gsub(/.*::/, '').split('').grep(/[A-Z]/).join.downcase + __af_version
            end
          end
        end
        
        klass.identifier_method = :id
      end
    end

    def __af_id
      @__af_id ||= self.send(self.class.identifier_method)
      case @__af_id
        when Integer
          Base62.encode(@__af_id)
        when String
          '!' + @__af_id
        else
          raise TypeError, "Unsupported ID class #{@__af_id.class.name}"
      end
    end

    def to_af
      @__af ||= "#{self.class.__af_type}-#{self.__af_id}"
    end

  end
end
