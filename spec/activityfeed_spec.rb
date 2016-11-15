require 'spec_helper'

describe ActivityFeed do
  it 'library has a version number' do
    expect(ActivityFeed::VERSION).not_to be nil
  end

  context 'clearing configuration' do
    before { ActivityFeed.find_or_create(:test); ActivityFeed.clear! }
    it 'should not have any more feeds' do
      expect(ActivityFeed.feed_names).to be_empty
    end
  end

  context '#feed_names' do
    before do
      ActivityFeed.clear!
      ActivityFeed.find_or_create(:test1)
      ActivityFeed.find_or_create(:test2)
    end

    subject { ActivityFeed.feed_names }
    it('should contain :test1 and :test2') { is_expected.to eq([:test1, :test2]) }
  end

  context 'multiple invocations of #of' do
    let(:tags_feed) { :new_tags }
    context 'with the same key' do
      it 'should return the same configuration instance' do
        expect(ActivityFeed.find_or_create(tags_feed)).to_not be_nil
        expect(ActivityFeed.find_or_create(tags_feed)).to equal(ActivityFeed.find_or_create(tags_feed))
      end
    end
  end

  context 'invalid feed name' do
    it 'should raise an exception' do
      expect { ActivityFeed.create }.to raise_error(ArgumentError)
    end
  end

end
