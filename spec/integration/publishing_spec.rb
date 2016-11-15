require 'spec_helper'
RSpec.describe 'ActivityFeed — Integration' do

  include_examples :events
  include_examples :hash_backend

  let(:feed_name) { :follower_feed }

  let(:feed_config) {
    ActivityFeed.find_or_create(feed_name) do |config|
      config.backend = backend
    end
  }

  let(:feed) { feed_config.for(user_list) }

  before :each do
    expect(feed.backend).to eq(backend)
    event_list.each(&:fire!)
  end
  
  context 'backend should be called' do
    it 'should contain three events' do
      event_list.each(&:fire!)
      expect(backend.size).to eq(2)
    end
    
    let(:pams_feed) { feed_config.for(pam) }
    
    it 'should have the right events' do
      expect(pams_feed.count).to eq(2)
      expect(pams_feed.unread_count).to eq(0)
    end
    
  end

end
