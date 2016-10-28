module ActiveFeed
  class Writer

    attr_accessor :users
    def initialize(users: [])
      self.users = users
    end

    def insert(event:, sort: 1)
      raise AbstractMethodCalledError, 'backend not defined'
    end

    def clear
      raise AbstractMethodCalledError, 'backend not defined'
    end

    def delete(event:)
      raise AbstractMethodCalledError, 'backend not defined'
    end
  end
end
