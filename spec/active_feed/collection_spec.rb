require 'spec_helper'

module ActiveFeed
  module Backend
    class FakeBackend < Base
    end
  end

  describe Collection do
    User = Struct.new(:username, :to_af)
    let(:backend) { ActiveFeed::Backend::FakeBackend.new }
    let(:configuration) { ActiveFeed.of(:news_feed) { |c| c.backend = backend } }
    let(:users) { [User.new('kig'), User.new('tom')] }
    let(:collection) { Collection.new(users, configuration) }
    let(:sort) { Time.now }

    it 'should delegate certain methods' do
      expect(users.is_a?(Array)).to be_truthy
      expect(collection.users).to eq(users)
      expect(backend).to receive(:publish).with(users[0], 1, sort)
      expect(backend).to receive(:publish).with(users[1], 1, sort)
      collection.publish(1, sort)
    end
  end
end
