require 'spec_helper'

module ActiveFeed
  module Backend
    RSpec.describe HashBackend do
      let(:hb) { HashBackend.new }
      
      context 'new backend' do
        it 'should be empty' do
          expect(hb.size).to eq(0)
        end
      end
    end
  end
end
