require 'spec_helper'

module ActivityFeed
  module Backend
    describe HashBackend do
      include_examples :users
      include_examples :hash_backend

      before do
        ActivityFeed.create_or_replace(:news) do |config|
          config.backend  = HashBackend.new
          config.max_size = 5
          config.per_page = 2
        end
      end

      let(:feed_config) { ActivityFeed.feed(:news) }
      subject(:user_feed) { feed_config.for(user_list) }
      
      context 'feeds backend' do
        it('should not be nil') { expect(ActivityFeed.feed(:news)).to_not be_nil }
        it('should not be nil') { expect(subject.backend).to_not be_nil }
        it('should be of type HashBackend') { expect(subject.backend).to be_kind_of(HashBackend) }
      end

      context 'HashBackend' do
        it('should be able to push and retrieve events') do
          feed_config.for(user_list)
        end
      end

      context 'publish' do
        it 'should push the event to the list' do

        end
      end
    end
  end
end
