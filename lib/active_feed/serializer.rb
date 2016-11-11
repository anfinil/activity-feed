module ActiveFeed
  module Serializer
    def dump(object)
      if object.respond_to?(:to_af)
        object.to_af
      else
        raise ObjectDoesNotImplementToAFError, object
      end
    end

    def load(string)
      
    end
  end
end
