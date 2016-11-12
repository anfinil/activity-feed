module ActiveFeed
  module Backend
    class FakeBackend < Base
      ActiveFeed::Feed::Collection::FORWARDED_METHODS.each do |method|
        self.send(:define_method, method) do |*|
          # noop
        end
      end
    end
  end

  class TestUser
    attr_accessor :id, :username

    def initialize(id = nil, username = nil)
      self.id       = id
      self.username = username
    end

    def self.define_users(usernames)
      users = []
      usernames.each_with_index do |username, index|
        users << self.new(index + 1, username.to_s)
      end
      users
    end

    USER_NAMES = %i(kig tom pam).freeze
    USERS = define_users(USER_NAMES).freeze
  end
end



