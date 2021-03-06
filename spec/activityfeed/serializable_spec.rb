require 'spec_helper'

module ActivityFeed

  RSpec.describe Serializable do
    include_context :users_context

    describe 'serialization' do
      subject { SerializableUser.new(10, :bob) }

      context 'default #to_af method' do
        it('serializes correctly') { is_expected.to serialize_to('su-%a') }
      end

      context 'with a special identifier method' do
        before do
          SerializableUser.instance_eval do
            self.identifier_get_method = :username
          end
        end
        it('serializes correctly') { is_expected.to serialize_to('su-!bob') }
      end

      context 'overridden method #to_a' do
        before do
          SerializableUser.class_eval do
            define_method(:to_af) { 'i am overridden'; }
          end
        end
        it('serializes correctly') { is_expected.to serialize_to('i am overridden') }
      end
    end

    context 'de-serialization' do
      describe 'numeric' do
        subject { 'su-%a' }
        it { is_expected.to deserialize_as(SerializableUser.new(10)) }
      end

      describe 'symbol' do
        subject { 'su-!kigster' }
        it { is_expected.to deserialize_as(SerializableUser.new(:kigster)) }
      end

      describe 'string' do
        subject { 'su-&kigster' }
        it { is_expected.to deserialize_as(SerializableUser.new('kigster')) }
      end
    end

    context 'serializing events' do
      include_context :events_context
    end
  end
end
