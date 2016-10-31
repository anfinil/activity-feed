require 'spec_helper'

module ActiveFeed
  describe Updater do
    User = Struct.new(:username)
    FakeBackend = Struct.new(:name) do
      def publish; end
    end

    let(:backend) { FakeBackend.new('fake') }
    let(:configuration) { Configuration.configure { |c| c.backend = backend }}

    it 'should propertly defined backend' do
      expect(configuration.backend).to eq(backend)
    end

    let(:targets) { [ User.new('kig'), User.new('tom')] }
    let(:updater) { Updater.new(targets: targets, configuration: configuration)}
    let(:sort) { Time.now }

    it 'should delegate certain methods' do
      expect(updater.targets).to eq(targets)
      expect(backend).to receive(:publish).with(targets: targets, event: 1, sort: sort)
      updater.publish(event: 1, sort: sort)
    end
  end
end
