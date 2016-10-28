require 'spec_helper'

describe ActiveFeed::Configuration do
  subject { ActiveFeed::Configuration }
  it('should respond to #config') { is_expected.to respond_to(:config) }

  context '#backend accessor' do
    subject { ActiveFeed::Configuration.configure }
    it('is defined') { is_expected.to respond_to(:backend) }

    context 'is assigned' do
      before do
        ActiveFeed::Configuration.configure do |c|
          c.backend = :fake_backend
        end
      end

      subject { ActiveFeed::Configuration.config.backend }
      it('and then returned') { is_expected.to eq(:fake_backend) }
    end
  end

  context 'access via a top level module' do
    before do
      ActiveFeed.config do |c|
        c.backend = :stuff
      end
    end
    it '#config accessor' do
      expect(ActiveFeed.config.backend).to eq(:stuff)
      expect(ActiveFeed.config(:backend)).to eq(:stuff)
      expect(ActiveFeed.config).to eq(ActiveFeed::Configuration.config)
    end
  end
end
