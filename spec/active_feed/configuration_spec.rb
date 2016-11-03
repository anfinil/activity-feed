require 'spec_helper'

module ActiveFeed
  # # Returns list of symbols representing each accessor available
  # CONFIG_ACCESSORS = (ActiveFeed::Configuration.configure.methods - Object.methods)
  #                      .grep(/=/) # grab only methods like per_page=
  #                      .map { |m| m[0..-2] } # strip the = sign
  #                      .map(&:to_sym) # and symbolize

  CONFIG_ACCESSORS = %i(name backend namespace default_page_size max_size on)
  describe Configuration do
    context 'config accessor' do
      subject { Configuration }
      it('should respond to #config') { is_expected.to respond_to(:config) }
    end

    context 'creating and configuring multiple feeds' do
      let(:multi_config) { ActiveFeed.configure }

      subject { multi_config }
      it('responds to :of') { is_expected.to respond_to(:of) }
      it('is a Hash') { is_expected.to be_kind_of(Hash) }
      it('is a ConfigurationHash') { is_expected.to be_kind_of(ConfigurationHash) }

      context 'when defining a specific feed' do
        let(:feed_name) { :latest_stories }
        before do
          multi_config.of(feed_name) do |config|
            config.backend = :new_backend
          end
        end

        subject { ActiveFeed.of(feed_name) }
        it('responds to :backend') { is_expected.to respond_to(:backend) }
        it('has its name correctly set') { expect(subject.name).to eql(feed_name) }
      end
    end

    context 'various ways of accessing configuration' do
      let(:backend) { :mongodb }

      before :each do
        ActiveFeed.of(:my_feed) { |c| c.backend = backend; c.namespace = :mfd }
        ActiveFeed.of(:my_feed) { |c| c.per_page = 60 }
      end

      let(:my_feed) { ::ActiveFeed.of(:my_feed) }

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

    context 'when passing namespace as argument' do
      before :each do
        ActiveFeed.of(:follower_activity, :ar) { |c| c.backend = true }
      end
      subject { ActiveFeed.of(:follower_activity).namespace }
      it('should correctly set the namespace') { is_expected.to eq(:ar) }
    end

  end
end
