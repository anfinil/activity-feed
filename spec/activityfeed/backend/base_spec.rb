require 'spec_helper'

module ActivityFeed
  module Backend
    describe Base do
      ActivityFeed::User::Collection::FORWARDED_METHODS.each do |method|
        context "method #{method}" do
          it 'should raise an exception' do
            expect { ActivityFeed::Backend::Base.new.send(method) }.to raise_error(AbstractMethodCalledWithoutAnOveride)
          end
        end
      end
    end
  end
end
