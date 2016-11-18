require 'spec_helper'

module ActivityFeed
  module Backend
    describe HashBackend do

      context 'unit tests' do
        include_context :users_context
        include_context :hash_backend_context
        include_context :events_context

        before do
          ActivityFeed.find_or_create(:news) do |config|
            config.backend  = HashBackend.new(config: config)
            config.max_size = 5
            config.per_page = 2
          end
        end

        let(:feed) { ActivityFeed.feed(:news) }
        subject(:user_feed) { feed.for(user_list) }

        context 'feeds backend' do
          it('should not be nil') { expect(ActivityFeed.feed(:news)).to_not be_nil }
          it('should not be nil') { expect(subject.backend).to_not be_nil }
          it('should be of type HashBackend') { expect(subject.backend).to be_kind_of(HashBackend) }
        end

        context 'writing to the feed' do
          it('should be able to push and retrieve events') do
            feed.for(user_list)
          end
        end
      end

      context 'integration tests' do
        include_context :events_context
        include_context :hash_backend_context

        let(:feed_name) { :follower_feed }

        let(:feed) {
          ActivityFeed.clear!
          ActivityFeed.find_or_create(feed_name) { |config| config.backend = hash_backend }
        }

        let(:users_feed) { feed.for(user_list) }
        let(:toms_feed) { feed.for(tom) }
        let(:kig_feed) { feed.for(kig) }

        before :each do
          expect(feed.backend).to eq(hash_backend)
          event_list.each(&:fire!)
        end

        context 'events for tom are fired' do
          it 'should only have toms key' do
            expect(hash_backend.size).to eq(1)
          end

          it 'should have correct number of events' do
            expect(toms_feed.count).to eq(3)
            expect(toms_feed.count_unread).to eq(3)
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
    end
  end
end
