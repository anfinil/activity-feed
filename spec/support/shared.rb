require_relative 'setup_data'

RSpec.shared_examples :users do |*|
  ActivityFeed::TestUser::USERS.each do |u|
    let(u.username) { u }
  end
  let(:user_list) { ActivityFeed::TestUser::USERS }
end

RSpec.shared_examples :events do |*|
  require 'support/events/abstract_event'
  let(:comment) { double('comment', user: kig) }
  let(:comment_event) {
    MyApp::Events::CommentedOnPostEvent.new(actor:  user_list.first,
                                            target: comment)
  }
end

RSpec.shared_examples :hash_backend do |*|
  include_examples :users
  include_examples :events
  let(:backend) { ActivityFeed::Backend::HashBackend.new }

  it 'should now respond to publish!' do
    expect(backend).to respond_to(:publish!)
  end
end

RSpec.shared_examples :fake_backend do |*|
  let(:backend) { ActivityFeed::Backend::FakeBackend.new }
  it 'should now respond to publish!' do
    expect(backend).to respond_to(:publish!)
  end
end
