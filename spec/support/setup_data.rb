module ActiveFeed
  module Backend
    class FakeBackend < Base
      ActiveFeed::Feed::Collection::FORWARDED_METHODS.each do |method|
        self.send(:define_method, method) do |*args|
        end
      end
    end
  end

  class TestUser < Struct.new(:username, :to_af)
    USERNAMES = %i(kig tom pam).freeze
    USERS     = USERNAMES.map { |username| self.new(username.to_s) }.freeze
  end
end



