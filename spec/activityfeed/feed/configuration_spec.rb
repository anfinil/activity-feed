require 'spec_helper'

module ActivityFeed
  module Feed
    describe Configuration do

      context 'creating feed configurations' do
        subject(:multi_config) { ActivityFeed.configure }
        
        it('responds to :feed') { is_expected.to respond_to(:create) }
        it('responds to :feed!') { is_expected.to respond_to(:create_or_replace) }
        it('is a Hash') { is_expected.to be_kind_of(Hash) }
        it('is a ConfigurationHash') { is_expected.to be_kind_of(Config) }

        context 'when defining a specific feed' do
          let(:feed_name) { :latest_stories }
          before do
            multi_config.create_or_replace(feed_name) do |config|
              config.backend = :new_backend
            end
          end

          subject { ActivityFeed.create_or_replace(feed_name) }

          it('responds to :backend') { is_expected.to respond_to(:backend) }
          it('has its name correctly set') { expect(subject.name).to eql(feed_name) }

          context 'auto-creates constants' do
            it('define the constant') do
              expect(ActivityFeed.const_defined?(:LatestStories)).to eq(true)
            end
          end
          
          context 'when passing namespace as argument' do
            subject { ActivityFeed.create_or_replace(:follower_activity, :ar).namespace }
            it('should correctly set the namespace') { is_expected.to eq(:ar) }
          end
        end

        context 'various ways of accessing configuration' do
          let(:backend) { :mongodb }
          before :each do
            ActivityFeed.create_or_replace(:my_feed) { |c| c.backend = backend; c.namespace = :mfd; c.per_page = 60 }
          end

          let(:my_feed) { ::ActivityFeed.feed(:my_feed) }

          context '#backend' do
            subject { my_feed.backend }
            it('equals the value set in #of') { is_expected.to eq(backend) }
          end

          context '#namespace' do
            subject { my_feed.namespace }
            it('equals the value set in #of') { is_expected.to eq(:mfd) }
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
        let(:user1) { double('Fred', to_af: 'fred') }
        let(:user2) { double('Josh', to_af: 'josh') }
        let(:user_list) { [user1, user2] }

        context 'for multiple users' do
          
          context 'a user array' do
            let(:sample_feed) { ActivityFeed.create_or_replace(:sample_feed).for(user_list) }
            it('should return Collection') { expect(sample_feed).to be_kind_of(ActivityFeed::User::Collection) }
            it('should return users array') { expect(sample_feed.users).to eq(user_list) }
          end

          context 'for a user proc' do
            let(:user_proc) { Proc.new { user_list.each { |u| yield u if block_given? } } }
            let(:sample_feed) { ActivityFeed.create_or_replace(:sample_feed).for(user_proc) }
            it('should return Collection') { expect(sample_feed).to be_kind_of(ActivityFeed::User::Collection) }
            it('should return users proc') { expect(sample_feed.users).to eq(user_proc) }
          end

        end

        context 'for a single user' do
          let(:sample_feed) { ActivityFeed.create_or_replace(:sample_feed).for(user1) }

          it('should return Feed') { expect(sample_feed).to be_kind_of(ActivityFeed::User::Proxy) }
          it('should return user1') { expect(sample_feed.user).to eq(user1) }
        end
      end
    end

  end
end