module ActivityFeed
  module Backend
    srand(1098010932048023984029)
    class FakeBackend
      include Backend
      ActivityFeed::User::Collection::FORWARDED_METHODS.each do |method|
        self.send(:define_method, method) do |*args|
          puts "#{self.inspect}: method: #{method} args: #{args}"
        end
      end
    end
  end

  class TestUser
    attr_accessor :id, :username
    
    include Serializable
    
    def initialize(id = nil, username = nil)
      self.id       = id
      self.username = username
    end

    def self.define_users(user_names)
      user_names.map do |user_name|
        self.new(rand(2**32), user_name.to_s)
      end
    end

    USER_NAMES = %i(kig tom pam).freeze
    USERS = define_users(USER_NAMES).freeze
  end
end
