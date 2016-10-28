require 'active_feed/version'

module ActiveFeed
  class Error < StandardError; end
  class AbstractMethodCalledError < ActiveFeed::Error; end
end
