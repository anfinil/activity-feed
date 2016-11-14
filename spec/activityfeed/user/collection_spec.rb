require 'spec_helper'

module ActivityFeed
  module User
    describe Collection do
      include_examples :users
      include_examples :fake_backend

      let(:configuration) { ActivityFeed.create_or_replace(:news_feed) { |c| c.backend = backend } }
      let(:collection) { Collection.new(users, configuration) }
      let(:sort) { Time.now }

      context 'when users is an ARRAY' do
        let(:users) { [kig, tom] }
        it 'should call #publish on the backend twice' do
          expect(users.is_a?(Array)).to be_truthy
          expect(collection.users).to eq(users)

          expect(backend).to receive(:publish!).with(users[0], 1, sort)
          expect(backend).to receive(:publish!).with(users[1], 1, sort)
          collection.publish!(1, sort)
        end
      end

      context 'when users is a Proc' do
        let(:user_list) { [[kig, tom], [pam]] }
        let(:users) { Proc.new { user_list.pop } }

        it 'should call #publish on the backend twice' do
          expect(user_list.is_a?(Array)).to be_truthy
          expect(collection.users.is_a?(Proc)).to be_truthy
          expect(collection.users).to eq(users)

          ActivityFeed::TestUser::USERS.reverse.each do |user|
            expect(backend).to receive(:publish!).with(user, 2, sort)
          end

          collection.publish!(2, sort)
        end
      end
    end
  end
end
