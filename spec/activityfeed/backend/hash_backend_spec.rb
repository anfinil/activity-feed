require 'spec_helper'
require 'base62-rb'
module ActivityFeed
  module Backend
    describe HashBackend do

      context 'unit tests' do
        include_context :serializable_users_context
        include_context :hash_backend_context

        before do
          ActivityFeed.feed(:news) do |config|
            config.backend        = backend
            config.backend.config = config
            config.max_size       = 5
            config.per_page       = 2
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
          let(:random_event) { double(:event, :id => 1) }
          it('should be able to push and retrieve events') do
            feed.for(user_list).publish!(random_event, 1)
            expect(user_list.map(&:id).uniq.size).to eq(3)
            expect(backend.size).to eq(3)
            expect(backend.paginate(user_list.first, 1, 100)).to eq([random_event])
          end
        end
      end

      context 'integration tests' do
        include_context :serializable_users_context
        include_context :hash_backend_context
        include_context :events_context

        before :each do
          backend.clear
          ActivityFeed.clear!
        end

        let!(:feed_name) { :follower_feed }

        let!(:feed) {
          ActivityFeed.feed(feed_name) { |config| config.backend = backend }
        }

        let(:bob_feed) { feed.for(bob) }
        let(:ben_feed) { feed.for(ben) }
        let(:tom_feed) { feed.for(tom) }

        context 'events for bob are fired' do
          context 'bob follows ben' do
            before { bob.follow!(ben) }
            it('should not populate activity feed') { expect(backend.size).to eq(0) }

            context 'tom follows ben' do
              before { tom.follow!(ben) }
              it('should not populate activity feed') { expect(backend.size).to eq(0) }

              context 'ben comments on pam' do
                before { ben.comment!('Hi Pam!', pam) }
                it('should now populate tom and bobs activity') { expect(backend.size).to eq(2) }
                it('should have specifically those two') { expect(backend.users.map(&:id)).to eq([bob.id, tom.id]) }

                context 'bob comments on ben' do
                  before { bob.comment!('Hi Ben!', ben) }
                  it('should not add to activity feed since bob has no followers') do
                    expect(backend.size).to eq(2)
                  end
                end

                context 'user keys' do
                  let(:user_keys) { backend.keys.sort }

                  it 'should have keys in the correct format' do
                    expect(user_keys).to include(bob.to_af)
                    expect(user_keys).to include(tom.to_af)
                    expect(user_keys.first).to match /^su-%/
                    expect(user_keys.first).to eq('su-%' + Base62.encode(bob.id))
                  end
                end

                context 'bobs feed' do
                  it 'should have correct number of events' do
                    expect(bob_feed.count).to eq(1)
                    expect(bob_feed.count_unread).to eq(1)
                  end

                  context '#reset_read_time!' do
                    before { bob_feed.read! }
                    it 'should reset bobs read time when called' do
                      expect(bob_feed.count).to eq(1)
                      expect(bob_feed.count_unread).to eq(0)
                    end
                  end

                  context '#paginate' do

                    before :each do
                      bob.follow!(pam)
                      pam.follow!(tom)
                    end

                    context 'boo' do
                      it 'should return events in a reverse chronological order' do
                        expect(bob_feed.count).to eq(2)
                        expect(bobs_events.size).to eq(2)
                        expect(bobs_events[0].created).to be > bobs_events[1].created
                      end

                      let(:bobs_events) { bob_feed.paginate(1, 10) }

                      it 'should have correct number of events' do
                        expect(bobs_events.size).to eq(2)
                        expect(bob_feed.count_unread).to eq(2)
                      end

                      it 'bob should be following pam' do
                        expect(pam.followers.map(&:username)).to include(bob.username)
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
