require 'spec_helper'

describe ActiveFeed::Configuration do
  subject { ActiveFeed::Configuration }
  it('should respond to #config') { is_expected.to respond_to(:config) }

  %i(backend per_page).each do |property|

    context "#{property} accessor" do
      subject { ActiveFeed::Configuration.configure }

      let(:property_value) { rand(20) }

      it('is defined') { is_expected.to respond_to(property) }

      context 'is assigned' do
        before do
          ActiveFeed::Configuration.configure do |c|
            c.send("#{property}=", property_value)
          end
        end

        subject { ActiveFeed::Configuration.config.send(property) }
        it('and then returned') { is_expected.to eq(property_value) }
      end
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
      expect(ActiveFeed.configure).to eq(ActiveFeed::Configuration.config)
    end
  end
end
