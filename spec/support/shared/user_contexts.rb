require_relative 'models'

RSpec.shared_context :users_context do |*|
  ActivityFeed::TestUser.users.each { |u| let(u.username) { u } }
  let(:user_list) { ActivityFeed::TestUser.users }
end

RSpec.shared_context :serializable_users_context do |*|
  ActivityFeed::SerializableUser.users.each { |u| let(u.username) { u } }
  let(:user_list) { ActivityFeed::SerializableUser.users }
end

