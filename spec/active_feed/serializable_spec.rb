require 'spec_helper'

module ActiveFeed
  class SerializableUser < TestUser
    include ActiveFeed::Serializable
  end

  RSpec.describe Serializable do
    include_examples :users
    before do
      class SerializableUser < TestUser
        include ActiveFeed::Serializable
      end
    end
    

    let(:object) { SerializableUser.new(10, :bob) }

    context 'default #to_af method' do
      subject { object.to_af }
      it('serializes correctly') { is_expected.to eq('su-%a') }

      context 'with a special identifier method' do
        before do
          SerializableUser.instance_eval do
            self.identifier_get_method = :username
          end
        end
        it 'uses overridden method' do
          expect(object.to_af).to eq('su-!bob')
        end
      end
    end

    context 'overridden method #to_a' do
      before do
        SerializableUser.class_eval do
          define_method(:to_af) { 'i am overridden'; }
        end
      end

      it 'uses overridden method' do
        expect(object.to_af).to eq('i am overridden')
      end
    end

    context 'restoring classes from the serialized format' do
      let(:string) { 'su-%a' }
      let(:klass_instance) { ActiveFeed::Serializable::Deserializer.klass_instance(string) }

      it 'should correctly instantiate the class' do
        expect(klass_instance).to be_kind_of(SerializableUser)
        expect(klass_instance.id).to eq(10)
      end
    end
  end
end
