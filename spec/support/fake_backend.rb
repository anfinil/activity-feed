
module ActiveFeed
  module Backend
    class FakeBackend < Base
      ActiveFeed::Collection::FORWARDED_METHODS.each do |method|
        self.send(:define_method, method) do |*args|
        end
      end
    end
  end
end

RSpec.shared_examples :fake_backend do |parameter|
  let(:backend) { ActiveFeed::Backend::FakeBackend.new }

  it 'should now respond to publish!' do
    expect(backend).to respond_to(:publish!)
  end
end
