module ActivityFeed

  class Error < StandardError
    def problem
      'suffered a general undertermined condition'
    end

    def initialize(object)
      super("Object of type #{object.class} value #{object} — #{problem}")
    end
  end

  class ObjectDoesNotImplementToAFError < ActivityFeed::Error
    def problem
      'object must implement #to_af instance method'
    end
  end

  class AbstractMethodCalledWithoutAnOveride < ActivityFeed::Error
    def problem
      'subclasses must be implementing these methods; you called an abstract top-level method.'
    end
  end
end
