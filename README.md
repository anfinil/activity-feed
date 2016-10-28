# ActiveFeed

[![Build Status](https://travis-ci.org/kigster/active_feed.svg?branch=master)](https://travis-ci.org/kigster/active_feed)
[![Code Climate](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/gpa.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/feed)
[![Test Coverage](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/coverage.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/coverage)
[![Issue Count](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/issue_count.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/feed)

## Fast, Redis-based, Write-Time Activity Feed for Social Networks

This gem attempts to fill two purposes:

 * define a minimalistic API for a typical event-based News Feed (a.k.a. Activity Feed)
 * provide a scalable default backend implementation using Redis. 


### Design 

This feed works best in a combination with application events, using any event-dispatching framework such as [Ventable](https://github.com/kigster/ventable), or [Wisper](https://github.com/krisleech/wisper).  As events are dispatched, an application component that generates activity feed must subscribes to a subset of the events that must appear in the feed. The events are converted to a compacted string-based schema, and stored in Redis using several internal data structures. 

This is a _write-time_ activity-feed implementation, where the speed optimization is focused on the _read-time_ performance, and the majority of the work is performed when the event is actually published. When the user requests their feed, it is constructed by returning the rendered versions of the events stored in the user's feed.

> The trade-off here is a possible delay in receiving an event in your feed. Because most of the work is performed at the event generation time, it must update feeds of all users who are subscribed to (or follow) a user (or any other model) that generated the event. If your system allows large audiences (eg, Twitter's celebrities have many millions of followers), then this approach suffers from a 'Bieber Problem'. For more information on the differences between _write-time_ and _read-time_ activity feed, please read [the following blog post by Lee Byron, Facebook](https://hashnode.com/post/architecture-how-would-you-go-about-building-an-activity-feed-like-facebook-cioe6ea7q017aru53phul68t1/answer/ciol0lbaa02q52s530vfqea0t)

Events can be a pure ruby classes, as long as they respond to the required methods (see below). They should also be able to render themselves in whatever formats needed, in order to show up within the application, but this functionality is outside of the scope of this gem.

### Features

Key features of this gem are:

 * Fast, constant time read operations of the news feed for any user
 * Compatibility with `twemproxy`, and it's ability to shard Redis data by user ID to support massive data sets across any number of servers
 * Ability to read the total, read and unread items count for any user
 * Ability to delete news feed items from a user's feed (ie, when the user unfollows somebody, etc).

It is my hope to keep this gem small and very targeted to solving a specific problem: _defining a basic newsfeed API_ and _reading and writing from an abstracted backend that can later be replaced with another underlying solution if needed_.
 
## Usage

First you need to configure the Feed with a valid backend implementation.

### Configuration

```ruby
  require 'active_feed'
  require 'active_feed/backend/redis'
  
  ActiveFeed.configure do |config|
     config.backend = ActiveFeed::Backend::Redis.new(
      redis: ::Redis.new(host: '127.0.0.1')      
     )
     config.per_page = 20
  end
```

Above awe've configured both the Redis client, and passed it to the `ActiveFeed::Backend::Redis` – which is an implementation of the backend data store.

### Writing Data to the Feed
 
```ruby
  # Given an @event (containing :actor, :object, :target, etc) and the list of users to 
  # update with this event, this is how we add it to the feed:
  require 'active_feed/writer'
  
  user_id_list = [1, 4, 545, 234234]
  
  writer = ActiveFeed::Writer.new(user_id_list)
  writer.add(sort: Time.now, event: @event)
```

#### Event Serialization

Events can be a pure ruby classes, but they must implement:

 * `#to_feed` instance method, which would return a short representation of the event using a string and IDs related to it. For example, it can be a short delimited string, with a type and a few IDs identifying the event.
 
 * `#from_feed` class method, which receives a string representation above and reconstructs the event to it's fullest.
 
### Reading Data from the Feed

Given a user,

```ruby
  require 'active_feed/reader'

  reader = ActiveFeed::Reader.new(@user)
  reader.paginate(page: 1).map do |item|
    # item here is a string, of the form, eg: 'l:23145:434243:343425', where l = like
    # and the three numbers are ids of actor, object and the object's target.
    
    ApplicationEvent.from_feed(item) # returns +UserLikedAStoryItem+ instance
      .render(:json)               # returns JSON string representation of the news feed item
         
  end.join(', ')

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

