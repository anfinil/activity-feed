require 'spec_helper'

module ActiveFeed
  describe Collection do
    include_examples :fake_backend

    User = Struct.new(:username, :to_af)
    let(:configuration) { ActiveFeed.of(:news_feed) { |c| c.backend = backend } }
    let(:collection) { Collection.new(users, configuration) }
    let(:sort) { Time.now }

    TEST_USERNAMES = %i(kig tom pam).freeze
    TEST_USERS = TEST_USERNAMES.map{ |username| User.new(username.to_s) }.freeze
    TEST_USERS.each do |u|
      let(u.username) { u }
    end

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

        TEST_USERS.reverse.each do |user|
          expect(backend).to receive(:publish!).with(user, 2, sort)
        end

        collection.publish!(2, sort)
      end
    end
  end
end
