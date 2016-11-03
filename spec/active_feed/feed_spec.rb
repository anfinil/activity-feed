require 'spec_helper'

module ActiveFeed
  module Backend
    class FakeBackend < Base
    end
  end

  describe Feed do
    User = Struct.new(:username)
    let(:users) { [User.new('kig'), User.new('tom')] }

    let(:backend) { ActiveFeed::Backend::FakeBackend.new(users) }
    let(:configuration) { ActiveFeed.of(:news_feed) { |c| c.backend = backend } }
    let(:feed) { Feed.new(users: users, config: configuration) }
    let(:sort) { Time.now }

    it 'should delegate certain methods' do
      expect(feed.users).to eq(users)
      expect(backend).to receive(:publish).with(users: users, event: 1, sort: sort)
      feed.publish(event: 1, sort: sort)
    end
  end
end
