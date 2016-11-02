require 'spec_helper'

module ActiveFeed
  module Backend
    class FakeBackend < AbstractBackend
    end
  end

  describe Feed do
    User = Struct.new(:username)

    let(:backend) { Backend::FakeBackend.new }
    let(:configuration) { ActiveFeed.of(:news_feed) { |c| c.backend = backend } }
    let(:users) { [User.new('kig'), User.new('tom')] }
    let(:feed) { Feed.new(users: users, config: configuration) }
    let(:sort) { Time.now }

    it 'should delegate certain methods' do
      expect(feed.users).to eq(users)
      expect(backend).to receive(:publish).with(users: users, event: 1, sort: sort)
      feed.publish(event: 1, sort: sort)
    end
  end
end
