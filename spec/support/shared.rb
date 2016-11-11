require_relative 'setup_data'

RSpec.shared_examples :test_backend do |*|
  let(:backend) { ActiveFeed::Backend::FakeBackend.new }

  it 'should now respond to publish!' do
    expect(backend).to respond_to(:publish!)
  end
end

RSpec.shared_examples :hash_backend do |*|
  let(:test_backend) { ActiveFeed::Backend::HashBackend.new }

  it 'should now respond to publish!' do
    expect(test_backend).to respond_to(:publish!)
  end
end

RSpec.shared_examples :test_users do |*|
  ActiveFeed::TestUser::USERS.each do |u|
    let(u.username) { u }
    let(:user_list) { [u] }
  end
end

RSpec.shared_examples :events do |*|
  require 'events/abstract_event'
end
