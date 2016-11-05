require 'spec_helper'

module ActiveFeed
  module Backend
    class FakeBackend < Base
    end
  end

  describe Collection do
    User = Struct.new(:username)
    let(:backend) { ActiveFeed::Backend::FakeBackend.new }
    let(:configuration) { ActiveFeed.of(:news_feed) { |c| c.backend = backend } }
    let(:users) { [User.new('kig'), User.new('tom')] }
    let(:collection) { Collection.new(users: users, config: configuration) }
    let(:sort) { Time.now }

    it 'should delegate certain methods' do
      expect(collection.users).to eq(users)
      expect(backend).to receive(:publish).with(users: users, event: 1, sort: sort)
      collection.publish(event: 1, sort: sort)
    end
  end
end
