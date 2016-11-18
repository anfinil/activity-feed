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
    attr_accessor :id, :username, :followers

    def initialize(id = nil, username = nil)
      self.id        = id
      self.username  = username
      self.followers = []
    end
    
    def follow!(followee)
      unless followee.followers.include?(self)
        followee.followers << self
        MyApp::Events::FollowedUserEvent.new(actor: self, target: followee)
      end
    end
    
    def comment!(body, other_user)
      MyApp::Events::CommentedOnPostEvent.new(actor: self, target: body, owner: other_user)
    end

    class << self
      def define_users(user_names)
        user_names.map do |user_name|
          self.new(rand(2**32), user_name.to_s)
        end
      end

      def user_names
        @user_names ||= %i(kig tom pam).freeze
      end

      def users
        @users ||= define_users(user_names).freeze
      end
    end
  end


  class SerializableUser < TestUser
    include ActivityFeed::Serializable

    def eql?(other)
      other.is_a?(self.class) && other.id == id && other.username == username
    end
  end
end

