require 'spec_helper'
require 'base62-rb'
module ActivityFeed
  module Backend
    describe HashBackend do

      context 'unit tests' do
        include_context :users_context
        include_context :hash_backend_context
        include_context :events_context

        before do
          ActivityFeed.feed(:news) do |config|
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
        include_context :hash_backend_context
        let!(:backend) { hash_backend }

        include_examples :backend_test
      end
    end
  end
end
