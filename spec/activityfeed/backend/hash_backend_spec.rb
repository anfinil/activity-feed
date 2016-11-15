require 'spec_helper'

module ActivityFeed
  module Backend
    describe HashBackend do
      include_examples :users
      include_examples :hash_backend
      include_examples :events

      before do
        ActivityFeed.find_or_create(:news) do |config|
          config.backend  = HashBackend.new
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
  end
end
