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
  let!(:toms_feed) { feed.for(tom) }
  let!(:kig_feed) { feed.for(kig) }

  before :each do
    event_list.each(&:fire!)
  end

  context 'events for tom are fired' do
    it 'should have the correct backend assigned' do
      expect(feed.backend).to eq(backend)
    end

    it 'should only have toms key' do
      expect(backend.size).to eq(1)
    end

    it 'should have toms key in the correct format' do
      expect(backend.keys.first).to eq(tom.to_af)
      expect(backend.keys.first).to match /^tu-%/
      expect(backend.keys.first).to eq('tu-%' + Base62.encode(tom.id))
    end

    it 'should have correct number of events' do
      expect(toms_feed.count).to eq(3)
      expect(toms_feed.count_unread).to eq(3)
    end

    context '#reset_read_time!' do
      before do
        toms_feed.read!
        comment_event2.fire!
      end

      it 'should reset toms read time when called' do
        expect(toms_feed.count).to eq(4)
        expect(toms_feed.count_unread).to eq(1)
      end
    end

    describe '#paginate' do
      subject(:toms_events) { toms_feed.paginate(1, 10) }

      it 'should return events in a reverse chronological order' do
        expect(toms_events[0].created).to be > toms_events[1].created
        expect(toms_events[1].created).to be > toms_events[2].created
      end

      it 'should equal to the reversed event list' do
        expect(toms_events).to eq(event_list.reverse)
      end
    end

  end
end
