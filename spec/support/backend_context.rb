require 'spec_helper'

# Requires definition of :backend to be a valid instance
# of the backend being tested.

RSpec.shared_examples :backend_test do |*|
  include_context :events_context

  let!(:feed_name) { :follower_feed }

  let!(:feed) {
    ActivityFeed.clear!
    ActivityFeed.feed(feed_name) { |config| config.backend = backend }
  }

  let!(:users_feed) { feed.for(user_list) }
  let!(:bobs_feed) { feed.for(bob) }
  let!(:ben_feed) { feed.for(ben) }

  before :each do
    event_list
  end

  context 'events for bob are fired' do
    it 'should have the correct backend assigned' do
      expect(feed.backend).to eq(backend)
    end

    it 'should only have one key' do
      expect(backend.size).to eq(1)
    end

    it 'should have bobs key in the correct format' do
      expect(backend.keys.first).to eq(ben.to_af)
      expect(backend.keys.first).to match /^su-%/
      expect(backend.keys.first).to eq('su-%' + Base62.encode(ben.id))
    end

    it 'should have correct number of events' do
      puts ben_feed.paginate(1, 100).map(&:inspect)
      expect(ben_feed.count).to eq(3)
      expect(ben_feed.count_unread).to eq(3)
    end

    context '#reset_read_time!' do
      before do
        bobs_feed.read!
        comment_event2.fire!
      end

      it 'should reset bobs read time when called' do
        expect(bobs_feed.count).to eq(4)
        expect(bobs_feed.count_unread).to eq(1)
      end
    end

    describe '#paginate' do
      subject(:bobs_events) { bobs_feed.paginate(1, 10) }

      it 'should return events in a reverse chronological order' do
        expect(bobs_events[0].created).to be > bobs_events[1].created
        expect(bobs_events[1].created).to be > bobs_events[2].created
      end

      it 'should equal to the reversed event list' do
        expect(bobs_events).to eq(event_list.reverse)
      end
    end

  end
end
