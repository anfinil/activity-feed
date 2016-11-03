require 'spec_helper'

describe ActiveFeed do
  it 'library has a version number' do
    expect(ActiveFeed::VERSION).not_to be nil
  end

  context 'clearing configuration' do
    before { ActiveFeed.of(:test); ActiveFeed.clear! }
    it 'should not have any more feeds' do
      expect(ActiveFeed.feed_names).to be_empty
    end
  end

  context '#feed_names' do
    before do
      ActiveFeed.clear!
      ActiveFeed.of(:test1)
      ActiveFeed.of(:test2)
    end

    subject { ActiveFeed.feed_names }
    it('should contain :test1 and :test2') { is_expected.to eq([:test1, :test2]) }
  end

  context 'multiple invocations of #of' do
    let(:feed) { :new_tags }
    context 'with the same key' do
      it 'should return the same configuration instance' do
        expect(ActiveFeed.of(feed)).to_not be_nil
        expect(ActiveFeed.of(feed)).to equal(ActiveFeed.of(feed))
      end
    end
  end

  context 'invalid feed name' do
    it 'should raise an exception' do
      expect { ::ActiveFeed.of }.to raise_error(ArgumentError)
    end
  end

end
