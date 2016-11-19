require_relative 'shared/user_contexts'
require_relative 'shared/backend_contexts'
require_relative 'shared/event_contexts'

# require_relative 'test_classes'
#
# RSpec.shared_context :users_context do |*|
#   ActivityFeed::TestUser.users.each { |u| let(u.username) { u } }
#   let(:user_list) { ActivityFeed::TestUser.users }
# end
#
# RSpec.shared_context :fake_backend_context do |*|
#   let(:fake_backend) { ActivityFeed::Backend::FakeBackend.new }
#   it 'should now respond to publish!' do
#     expect(fake_backend).to respond_to(:publish!)
#   end
# end
#
# RSpec.shared_context :serializable_users_context do |*|
#   ActivityFeed::SerializableUser.users.each { |u| let(u.username) { u } }
#   let(:user_list) { ActivityFeed::SerializableUser.users }
# end
#
# RSpec.shared_context :hash_backend_context do |*|
#   let(:backend) { ActivityFeed::Backend::HashBackend.new  }
#   let(:feed_name) { :hash_feed }
#   let(:feed) { ActivityFeed.feed(feed_name).configure { |c| c.backend = backend} }
# end
#
# RSpec.shared_context :events_context do |*|
#   include_context :serializable_users_context
#
#   let(:bob) { ActivityFeed::SerializableUser.new(1, 'Bob') }
#   let(:ben) { ActivityFeed::SerializableUser.new(2, 'Ben') }
#
#   let(:comment_event1) { bob.comment!('Hi, Ben!', ben) }
#   let(:comment_event2) { ben.comment!('Hi, Bob!', bob) }
#
#   let(:follow_event1) { bob.follow!(ben) }
#   let(:follow_event2) { tom.follow!(ben) }
#
#   let(:event_list) { [follow_event1, follow_event2, comment_event1] }
# end
