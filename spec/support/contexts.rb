require_relative 'test_classes'

RSpec.shared_context :fake_backend_context do |*|
  let(:fake_backend) { ActivityFeed::Backend::FakeBackend.new }
  it 'should now respond to publish!' do
    expect(fake_backend).to respond_to(:publish!)
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
      config: ActivityFeed.feed(:hash_feed)
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

  let(:comment_event) { MyApp::Events::CommentedOnPostEvent.new(actor: pam, target: comment, owner: comment.user) }
  let(:follow_event1) { MyApp::Events::FollowedUserEvent.new(actor: kig, target: tom, owner: tom) }
  let(:follow_event2) { MyApp::Events::FollowedUserEvent.new(actor: pam, target: tom, owner: tom) }

  let(:event_list) { [follow_event1, follow_event2, comment_event] }
end
