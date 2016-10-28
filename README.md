[![Build Status](https://travis-ci.org/kigster/active_feed.svg?branch=master)](https://travis-ci.org/kigster/active_feed)

# ActiveFeed

## Fast, Redis-based, Write-Time Activity Feed for Social Networks

This gem attempts to fill two purposes:

 * define a minimalistic API for a typical event-based News Feed (a.k.a. Activity Feed)
 * provide a scalable default backend implementation using Redis. 
 
As a result, this is a very fast Redis-backed user activity feed of various events relevant to the given user. As events arrive, they are converted to a compacted string-based schema, and stored in several sets within Redis, using several data structures, such as Ordered Set and List. 

This is a _write-time_ activity-feed implementation, where the speed optimization is focused on the _read-time_ performance, and the majority of the work is performed when the event is actually published. When the user requests their feed, it is constructed by returning the rendered versions of the events stored in the user's feed. 

Events can be any ruby classes that application provides, as long as they respond to several required methods (see below). They should also be able to render themselves in order to show up within the application, but this functionality is outside of the scope of this gem.

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

