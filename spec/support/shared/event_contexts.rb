require 'spec_helper'

require_relative 'events/commented_on_post_event'
require_relative 'events/followed_user_event'

RSpec.shared_context :events_context do |*|
  include_context :serializable_users_context

  let(:bob) { ActivityFeed::SerializableUser.new(1, 'Bob') }
  let(:ben) { ActivityFeed::SerializableUser.new(2, 'Ben') }
end
