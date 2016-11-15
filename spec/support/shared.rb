require_relative 'setup_data'

RSpec.shared_examples :fake_backend do |*|
  let(:backend) { ActivityFeed::Backend::FakeBackend.new }
  it 'should now respond to publish!' do
    expect(backend).to respond_to(:publish!)
  end
end

RSpec.shared_examples :users do |*|
  ActivityFeed::TestUser::USERS.each do |u|
    let(u.username) { u }
  end
  let(:user_list) { ActivityFeed::TestUser::USERS }
end

RSpec.shared_examples :hash_backend do |*|
  let(:backend) { ActivityFeed::Backend::HashBackend.new }

  it 'should now respond to publish!' do
    expect(backend).to respond_to(:publish!)
  end
end

RSpec.shared_examples :events do |*|
  include_examples :users
  require 'support/events/abstract_event'
  let(:comment) { double('comment', user: tom) }
  let(:comment_event) {
    MyApp::Events::CommentedOnPostEvent.new(actor: pam, target: comment)
  }
  let(:follow_event1) {
    MyApp::Events::FollowedUserEvent.new(actor: kig, target: tom)
  }
  let(:follow_event2) {
    MyApp::Events::FollowedUserEvent.new(actor: pam, target: tom)
  }
  let(:event_list) { [follow_event1, follow_event2, comment_event] }
end

RSpec.shared_examples :publishing do |*|
end
