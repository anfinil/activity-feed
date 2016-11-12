require 'spec_helper'

module ActiveFeed
  module Backend
    describe HashBackend do
      include_examples :users
      include_examples :hash_backend

      let(:feed) {
        ActiveFeed.configure.feed(:news) do |config|
          config.backend  = HashBackend.new
          config.max_size = 5
          config.per_page = 2
        end
      }

      context 'hash backend' do
        subject { feed }
        it('should be HashBackend') { expect(subject.backend).to be_kind_of(HashBackend) }
        it('should be able to push and retrieve events') do
          feed.for(user_list)
        end
      end
    end
  end
end
