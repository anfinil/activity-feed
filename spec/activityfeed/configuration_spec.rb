require 'spec_helper'

module ActivityFeed
  describe Configuration do

    context 'creating feed configurations' do
      let(:registry) { ::ActivityFeed }

      context 'when defining a specific feed' do
        let(:feed_name) { :latest_stories }
        subject(:activity_feed) {
          registry.define(feed_name) do |config|
            config.backend = :new_backend
          end
        }

        it('responds to :backend') do
          expect(activity_feed).to respond_to(:backend)
        end
        it('has its name correctly set') { expect(activity_feed.name).to eql(feed_name) }

        context 'auto-creates constants and methods' do
          it('defines the method') do
            expect(subject.name).to eq(:latest_stories)
            expect(registry.latest_stories).to eq(ActivityFeed.define(:latest_stories))
          end
        end
      end

      context 'various ways of accessing configuration' do
        let(:backend) { :mongodb }
        before :each do
          registry.define(:my_feed) { |c| c.backend = backend; c.per_page = 60 }
        end

        let(:my_feed) { ::ActivityFeed.define(:my_feed) }

        context '#backend' do
          subject { my_feed.backend }
          it('equals the value set in #of') { is_expected.to eq(backend) }
        end

        context '#per_page' do
          subject { my_feed.per_page }
          it('equals the value set in #of') { is_expected.to eq(60) }
        end

        context '#max_size' do
          subject { my_feed.max_size }
          it('equals the defualt value') { is_expected.to eq(1000) }
        end
      end
    end

    context 'generating feed instances' do
      include_context :fake_backend_context

      let(:user1) { double('Fred', to_af: 'fred') }
      let(:user2) { double('Josh', to_af: 'josh') }
      let(:user_list) { [user1, user2] }

      before do
        ActivityFeed.define(:sample_feed) do |config|
          config.backend = fake_backend
        end
      end

      context 'for multiple users' do

        context 'a user array' do
          let(:sample_feed) { ActivityFeed.define(:sample_feed).for(user_list) }
          it('should return Collection') { expect(sample_feed).to be_kind_of(ActivityFeed::User::Collection) }
          it('should return users array') { expect(sample_feed.users).to eq(user_list) }
        end

        context 'for a user proc' do
          let(:user_proc) { Proc.new { user_list.each { |u| yield u if block_given? } } }
          let(:sample_feed) { ActivityFeed.define(:sample_feed).for(user_proc) }
          it('should return Collection') { expect(sample_feed).to be_kind_of(ActivityFeed::User::Collection) }
          it('should return users proc') { expect(sample_feed.users).to eq(user_proc) }
        end

      end

      context 'for a single user' do
        let(:sample_feed) { ActivityFeed.define(:sample_feed).for(user1) }

        it('should return Feed') { expect(sample_feed).to be_kind_of(ActivityFeed::User::Proxy) }
        it('should return user1') { expect(sample_feed.user).to eq(user1) }
      end
    end
  end

end
