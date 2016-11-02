require 'spec_helper'

module ActiveFeed
  # # Returns list of symbols representing each accessor available
  # CONFIG_ACCESSORS = (ActiveFeed::Configuration.configure.methods - Object.methods)
  #                      .grep(/=/) # grab only methods like per_page=
  #                      .map { |m| m[0..-2] } # strip the = sign
  #                      .map(&:to_sym) # and symbolize

  CONFIG_ACCESSORS = %i(name backend namespace default_page_size max_size on)
  describe Configuration do
    context '#config' do
      subject { Configuration }
      it('should respond to #config') { is_expected.to respond_to(:config) }
    end

    context 'enclosing multi-configuration hash' do
      let(:multi_config) { ActiveFeed.configure }
      subject { multi_config }

      it('responds to :of') { is_expected.to respond_to(:of) }

      it('is a Hash') { is_expected.to be_kind_of(Hash) }

      it('is a ConfigurationHash') { is_expected.to be_kind_of(ConfigurationHash) }

      context 'when defining a specific feed' do
        let(:feed_name) { :news_feed }
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
      let(:backend) { :stuff }

      before :each do
        ActiveFeed.of(:my_feed) { |c| c.backend = backend; c.namespace = :mfd }
        ActiveFeed.of(:my_feed) { |c| c.per_page = 60 }
      end

      context '#backend' do
        subject { ::ActiveFeed.configure.of(:my_feed).backend }
        it('equals the value set in #of') { is_expected.to eq(backend) }
      end

      context '#namespace' do
        subject { ::ActiveFeed.configure.of(:my_feed).namespace }
        it('equals the value set in #of') { is_expected.to eq(:mfd) }
      end

      context '#per_page' do
        subject { ::ActiveFeed.configure.of(:my_feed).per_page }
        it('equals the value set in #of') { is_expected.to eq(60) }
      end

      context '#max_size' do
        subject { ::ActiveFeed.configure.of(:my_feed).max_size }
        it('equals the defualt value') { is_expected.to eq(1000) }
      end

      context 'multiple invocations of #of' do
        let(:feed_name) { :my_feed }
        context 'with the same key' do
          it 'should return the same configuration instance' do
            expect(ActiveFeed.of(:some_feed)).to_not be_nil
            expect(ActiveFeed.of(:some_feed)).to equal(ActiveFeed.of(:some_feed))
          end
        end
      end
    end

    context 'invalid feed name' do
      it 'should raise an exception' do
        expect { ::ActiveFeed.of }.to raise_error(ArgumentError)
      end
    end
  end
end
