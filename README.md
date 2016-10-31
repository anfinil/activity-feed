# ActiveFeed

### WARNING: this project is under active development, and is not yet finished.

[![Gem Version](https://badge.fury.io/rb/active_feed.svg)](http://rubygems.org/gems/active_feed)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/kigster/active_feed/master/LICENSE.txt)

[![Build Status](https://travis-ci.org/kigster/active_feed.svg?branch=master)](https://travis-ci.org/kigster/active_feed)
[![Code Climate](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/gpa.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/feed)
[![Test Coverage](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/coverage.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/coverage)
[![Issue Count](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/issue_count.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/feed)


## Fast, Redis-based, Write-Time Activity Feed for Social Networks

This is "from-the-ground-up" created library attempts to fill two purposes:

 * define a minimalistic API for a typical event-based News Feed (a.k.a. Activity Feed)
 * provide a scalable default backend implementation using Redis
 * allow connecting the application to multiple independent activity feeds that may or may not share Redis backend.

### Key Features

The following is a short list of high-level features intended to be supported:

1. Updating the feed is generally done for a set of users. Typical example being an event distributed to all followers. Here we support:

    * _Publishing_ a new event to all related users.
    * _Deleting_ an event from all related user feeds.
    * _Aggregating_ similar events within each user's feed (not planned for v1.0)

3. Reading the feed is done for a given user with the purpose of rendering the news feed.

    * Fetching and _paginating_ the news feed items for the purpose of rendering them on the UI.
    * _Saving the last viewing time_ for a given user.
    * Fast, _constant time read operations_ on the news feed, for any user due to it's pre-computed design.
    * Redis backend Compatibility with [`twemproxy`](https://github.com/twitter/twemproxy), and it's ability to shard Redis backend, and to support massive data sets across any number of servers
    * Quick lookup of the _number of the new (unread)_ items in the user's feed

It is my hope to keep this gem small and very targeted to solving a specific problem, which is **to define a basic activity feed API for reading and writing from/to a backend, which can be swapped out with another implementation.**

### Design

This feed works best in a combination with application events, using any event-dispatching framework such as [Ventable](https://github.com/kigster/ventable), or [Wisper](https://github.com/krisleech/wisper).  As events are dispatched, an application component that generates activity feed must subscribe to a subset of the events — those that must appear in the feed. The events are typically converted to a compact string-based schema, and stored in Redis using several internal data structures.

This is a _write-time_ activity-feed implementation, where the speed optimization is focused on the _read-time_ performance, and the majority of the work is performed when the event is actually published. When the user requests their feed, it is constructed by returning the rendered versions of the events stored in the user's feed. Because the feed is pre-computed, the rendering phase should be very quick, making users happy with a snappy activity feed in the application.


#### Speed vs Real-time Trade-Off

The trade-off here is a possible delay in receiving an event in your feed. Because most of the work is performed at the event generation time, it must update feeds of all users who are subscribed to (or follow) a user (or any other model) that generated the event. If your system allows large audiences (eg, Twitter's celebrities have many millions of followers), then this approach suffers from a 'Bieber Problem'. For more information on the differences between _write-time_ and _read-time_ activity feed, please read [the following blog post by Lee Byron, Facebook](https://hashnode.com/post/architecture-how-would-you-go-about-building-an-activity-feed-like-facebook-cioe6ea7q017aru53phul68t1/answer/ciol0lbaa02q52s530vfqea0t)

Events can be a pure ruby classes, as long as they respond to the required methods (see below). They should also be able to render themselves in whatever formats needed, in order to show up within the application, but this functionality is outside of the scope of this gem.


## Usage

First you need to configure the Feed with a valid backend implementation.

### Configuration

```ruby
  require 'active_feed'
  require 'active_feed-redis'

  ActiveFeed.configure do |config|
     config[:news_feed].backend = ActiveFeed::Backend::Redis.new(
      redis: ::Redis.new(host: '127.0.0.1')
     )
     config.per_page = 20
  end
```

Above awe've configured both the Redis client, and passed it to the `ActiveFeed::Backend::Redis` – which is an implementation of the backend data store.

### Writing Data to the Feed

```ruby
  require 'active_feed/updater'

  # First we define list of users (or "owners") of the activity feed to be
  # populated with the given event.
  user_id_list = [1, 4, 545, 234234]

  # Next, we instantiate the updater by passing the list of users,
  # and then we publish the event across all of the corresponding feeds.
  ActiveFeed::Updater.new(user_id_list).publish(sort: Time.now, event: event)
```

Instead of passing the list of user IDs, you can pass an AREL statement,
or a block which should return the next element in the array when called,
or nil when exhausted.

For any object types besides Integer, ActiveFeed will call a method
:to_af on the object, in order to receive a string representation of
that object.

```ruby
  # This is just an example of how you could return AREL statement
  # which can then be fetched in groups (pages) of users and split into
  # several parallel jobs by ActiveFeed.

  updater = ActiveFeed::Updater.new(  User.where(follower: event.actor) )
  updater.publish(sort: Time.now, event: event)
```

#### Event Serialization

Events can be a pure ruby classes, but they must implement:

 * `#to_af` instance method, which would return a short representation of the event using a string and IDs related to it. For example, it can be a short delimited string, with a type and a few IDs identifying the event.

 * `#from_af` class method, which receives a string representation generated above, and reconstructs object associated with the event, needed for rendering it.

### Reading Data from the Feed

Given a user,

```ruby
  require 'active_feed/reader'

  reader = ActiveFeed::Reader.new(User.where(username: 'kig').first)

  reader.paginate(page: 1, per_page: 20).map do |activity|
    event = ApplicationEvent.from_af(activity)  # returns a +UserLikedAStoryItem+ instance
    event.render(:json)                         # returns JSON string representation of the news feed item
  end.join(',')

```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_feed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_feed


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/active_feed.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

