require 'spec_helper'

module ActiveFeed
  RSpec.describe Serializable do
    class SerializableUser < TestUser
      include ActiveFeed::Serializable
    end
    
    include_examples :users

    let(:bob) { SerializableUser.new(10, :bob) }
    describe '#to_af' do
      subject { bob.to_af }
      it('serializes correctly') { is_expected.to eq('su1-a') }
    end
  end
end
