require 'spec_helper'
require_relative 'event_contexts'

# Requires definition of :backend to be a valid instance
# of the backend being tested.
RSpec.shared_context :hash_backend_context do |*|
  let(:backend) { ActivityFeed::Backend::HashBackend.new }
  let(:feed_name) { :hash_feed }
  let(:feed) { ActivityFeed.feed(feed_name).configure { |c| c.backend = backend } }
end


RSpec.shared_context :fake_backend_context do |*|
  let(:backend) { ActivityFeed::Backend::FakeBackend.new }
  let(:feed_name) { :fake_feed }
  let(:feed) { ActivityFeed.feed(feed_name).configure { |c| c.backend = backend } }
end


RSpec.shared_context :backend_validation_context do |*|

end
