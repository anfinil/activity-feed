module ActiveFeed
  class Writer

    attr_accessor :users
    def initialize(users: [])
      self.users = users
    end

    def insert(sort:, value:)
    end

    def clear
    end

    def delete(value:)
    end
  end
end
