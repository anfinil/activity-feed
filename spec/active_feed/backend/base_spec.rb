require 'spec_helper'

module ActiveFeed
  module Backend
    describe Base do
      ActiveFeed::Collection::FORWARDED_METHODS.each do |method|
        context "method #{method}" do
          it 'should raise an exception' do
            expect { ActiveFeed::Backend::Base.new.send(method) }.to raise_error(AbstractMethodCalledWithoutAnOveride)
          end
        end
      end
    end
  end
end
