require 'spec_helper'

module ActivityFeed
  class Exploder
    include Backend
  end
  RSpec.describe Backend do
    ActivityFeed::Backend::REQUIRED_METHODS.each do |method|
      context "method #{method}" do
        it 'should raise an exception' do
          expect { ActivityFeed::Exploder.new.send(method) }.to raise_error(AbstractMethodCalledError)
        end
      end
    end
  end
end
