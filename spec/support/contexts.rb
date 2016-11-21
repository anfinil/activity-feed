require_relative 'test_classes'

RSpec.shared_context :fake_backend_context do |*|
  let(:fake_backend) { ActivityFeed::Backend::FakeBackend.new }
  it 'should now respond to add' do
    expect(fake_backend).to respond_to(:add)
  end
end

RSpec.shared_context :users_context do |*|
  ActivityFeed::TestUser::USERS.each do |u|
    let(u.username) { u }
  end
  let(:user_list) { ActivityFeed::TestUser::USERS }
end

RSpec.shared_context :hash_backend_context do |*|
  let(:hash_backend) {
    ActivityFeed::Backend::HashBackend.new(
      config: ActivityFeed.define(:hash_feed)
    )
  }

  before do
    hash_backend.config.configure do |c|
      c.backend  = hash_backend
      c.per_page = 5
    end
  end
end

RSpec.shared_context :events_context do |*|
  include_context :users_context

  require 'support/events/abstract_event'
  let(:comment) { double('comment', user: tom) }

  let(:comment_event_new) {
    ->(user, comment) {
      MyApp::Events::CommentedOnPostEvent.new(actor: user, target: comment, owner: comment.user) }
  }

  let(:follow_event_new) {
    ->(follower, followee) {
      MyApp::Events::FollowedUserEvent.new(actor: follower, target: followee)
    }
  }

  let(:comment_event1) { comment_event_new.call(pam, comment) }
  let(:comment_event2) { comment_event_new.call(kig, comment) }
  let(:follow_event1) { follow_event_new.call(kig, tom) }
  let(:follow_event2) { follow_event_new.call(pam, tom) }

  let(:event_list) { [follow_event1, follow_event2, comment_event1] }
  end
