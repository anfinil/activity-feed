require 'spec_helper'

module ActiveFeed

  # Returns list of symbols representing each accessor available
  CONFIG_ACCESSORS = (ActiveFeed::Configuration.configure.methods - Object.methods) \
    .grep(/=/) # grab only methods like per_page=
                       .map { |m| m[0..-2] } # strip the = sign
                       .map(&:to_sym) # and symbolize

  describe Configuration do
    context '#config' do
      subject { Configuration }
      it('should respond to #config') { is_expected.to respond_to(:config) }

    end

    context 'configurable accessors' do
      it 'should return known accessors' do
        expect(CONFIG_ACCESSORS).to include(:per_page)
        expect(CONFIG_ACCESSORS).to include(:backend)
      end

      CONFIG_ACCESSORS.each do |property|
        context "#{property} accessor" do
          subject { Configuration.configure }
          it('is defined') { is_expected.to respond_to(property) }

          context 'is assigned' do
            let(:property_value) { rand(20) }
            before do
              Configuration.configure do |c|
                c.send("#{property}=", property_value)
              end
            end

            subject { Configuration.config.send(property) }
            it('and then returned') { is_expected.to eq(property_value) }
          end
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
        expect(::ActiveFeed.config.backend).to eq(:stuff)
        expect(::ActiveFeed.config(:backend)).to eq(:stuff)
        expect(::ActiveFeed.config).to eq(Configuration.config)
        expect(::ActiveFeed.configure).to eq(Configuration.config)
      end
    end
  end
end
