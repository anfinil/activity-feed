require 'spec_helper'

module ActivityFeed
  module User
    describe Collection do
      include_context :users_context
      include_context :fake_backend_context

      before do
        ActivityFeed.clear!
      end

      let(:configuration) {
        ActivityFeed.feed(feed_name) do |c|
          c.backend = backend
        end
      }
      let(:collection) {
        Collection.new(users, configuration) 
      }
      let(:sort) { 5 }

      context 'when users is an ARRAY' do
        let(:users) { [kig, tom] }
        it 'should call #publish on the backend twice' do
          expect(users.is_a?(Array)).to be_truthy
          expect(collection.users).to eq(users)
          expect(collection.backend).to eq(backend)

          expect(backend).to receive(:publish!).with(users[0], 1, sort)
          expect(backend).to receive(:publish!).with(users[1], 1, sort)
          collection.publish!(1, sort)
        end
        context 'empty array' do
          let(:users) { [] }
          it 'should not call #publish on the backend' do
            expect(users.is_a?(Array)).to be_truthy
            expect(collection.users).to eq(users)
            expect(collection.backend).to eq(backend)

            expect(backend).not_to receive(:publish!)
            collection.publish!(1, sort)
          end
        end
      end

      context 'when users is an ARRAY of ARRAYs' do
        let(:users) { [[kig, tom], [ pam ]] }
        let(:flattened_users) { [ kig, tom, pam ]}
        it 'should call #publish on the backend twice' do
          expect(users.is_a?(Array)).to be_truthy
          expect(collection.users).to eq(users)
          expect(collection.backend).to eq(backend)

          flattened_users.each do |u|
            expect(backend).to receive(:publish!).with(u, 1, sort)
          end
          
          collection.publish!(1, sort)
        end
      end

      context 'when users is a Proc' do
        let(:user_list) { [[kig, tom], [pam]] }
        let(:users) { Proc.new { user_list.pop } }
        let(:event) { 10 }

        it 'should call #publish on the backend twice' do
          expect(user_list.is_a?(Array)).to be_truthy
          expect(collection.users.is_a?(Proc)).to be_truthy
          expect(collection.users).to eq(users)
          expect(collection.backend).to eq(backend)
        end
        
        it 'should proxy publish! to each user proxy' do
          user_list.flatten.each do |u|
            expect(backend).to receive(:publish!).with(u, event, sort)
          end
          collection.publish!(event, sort)

        end
      end
    end
  end
end
