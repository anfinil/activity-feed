## ActiveFeed


This is a ruby implementation of **a fast and scalable "write-time" activity feed for typical Social Networks, that comes with a Redis-based default backend implementation, but allows that to be swapped out**. 
 
This project is sponsored by [Simbi, Inc.](https://simbi.com)

> **WARNING: this project is under active development, and is not yet finished**

[![Gem Version](https://badge.fury.io/rb/activefeed.svg)](https://badge.fury.io/rb/activefeed)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/kigster/activefeed/master/LICENSE.txt)

[![Build Status](https://travis-ci.org/kigster/activefeed.svg?branch=master)](https://travis-ci.org/kigster/activefeed)
[![Code Climate](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/gpa.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/feed)
[![Test Coverage](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/coverage.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/coverage)
[![Issue Count](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/issue_count.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/feed)


> **[Overview, Usage and Installation](https://github.com/kigster/activefeed/blob/master/README.md)**

> [Design](https://github.com/kigster/activefeed/blob/master/DESIGN.md)

> [Serialization and De-Serialization](https://github.com/kigster/activefeed/blob/master/SERIALIZATION.md)

> [Key Features](https://github.com/kigster/activefeed/blob/master/FEATURES.md)

### What's an Activity Feed?

Here is a typical text-based activity feed that is so common today on social networks:

[![Example](https://raw.githubusercontent.com/kigster/activefeed/master/uml/active-feed-example.png)](https://raw.githubusercontent.com/kigster/activefeed/master/doc/active-feed-example.png)

### Overview

This is a "from-the-ground-up" written library that implements the concept of an activity feed, and hopes to address the following goals:

 * To define a minimalistic API for a typical event-based activity feed, without tying it to any concrete backend
 * To make it easy to implement and plug in a new type of backend, eg. using Couchbase or MongoDB 
 * To provide a scalable default backend implementation using Redis, which can support millions of users via sharding 
 * To support multiple activity feeds within the same application, but used for different purposes, eg. activity feed of my followers, versus activity feed of my own actions.

### Usage

First you need to configure the Feed with a valid backend implementation.

#### Configuration

```ruby
    require 'activefeed'
    require 'redis'
      
    ActiveFeed.configure do |config|
      config.of(:friends_news) do |friends_news|
        friends_news.backend      = ActiveFeed::Redis::Backend.new(
          redis: -> { ::Redis.new(host: '127.0.0.1') },
        ),
        # how many items can be in the feed
        friends_news.max_size     = 1000
        friends_news.per_page     = 20       
      end
    end
```

Above we've configured the Redis client, passed the proc that creates new Redis clients into the Redis Backend for `ActiveFeed`. We've also limited the max size of the feed to a 1000 items – which are typically 1000 most recent events.

##### Multiple Independent Activity Feeds

But sometimes a single feed is not enough. What if we wanted to maintain two separate personalized feeds for each user: one would be news articles the user subscribes to, and the other would be a more typical activity feed. 

We can create an additional activity feed, say for followers, and call it `:followers` at the same time, and configure it with a slightly different backend. Because we expect this activity feed to be more taxing – as events might have large audiences — we'll wrap it in the `ConnectionPool` that will create several connections that can be used concurrently:

```ruby
    require 'activefeed'
    require 'redis'
    
    ActiveFeed.configure do |config|
    
      # This is the feed of news articles based on user subscription preferences.
      config.of(:friends_news) do |friends_news| 
        friends_news.backend = ActiveFeed::Redis::Backend.new(
          redis: ::Redis.new(host: '127.0.0.1')
        )
        friends_news.per_page = 20
      end    
    
      # This is the feed of events associated with the followers.
      # We use ConnectionPool because we anticipate higher load.
      config.of(:followers) do |followers_feed| 
        followers_feed.backend = ActiveFeed::Redis::Backend.new(
          redis: ConnectionPool.new(size: 5, timeout: 5) { 
            ::Redis.new(host: '192.168.10.10', port: 9000) 
        })
      end
    end
```

##### Referencing Multiple Feeds

So how do you access the feed from your code? Please check the UML diagram above to see how objects are returned.

When we called `ActivityFeed.of(:friends_news)` for the very first time, the library has created a hash key `:friends_news` that from now on will point to this instance of the feed configuration within the application.

In addition, the gem also created a constant under the `ActiveFeed` namespace. For example, given a name such as `:friends_news` the constant defined as `ActiveFeed::FriendsNews`. 

Both syntaxes can be used interchangeably, just make sure you execute initialization of the configuration before you reference the constant.
 
```ruby
   ActivityFeed::FriendsNews === ActivityFeed.of(:friends_news) 
   # => true
```

#### Publishing Data to the Feed

When we publish events to the feeds, we typically (although not always) do it for many feeds at the same time. This is why the write operations expect a list of users, or an enumeration, or a block yielding batches of the users:

```ruby
    require 'activefeed'
    
    # First we define list of users (or "owners") of the activity feed to be
    # populated with the given event 
    users = [1, 4, 545, 234234]
    
    # Next, we instantiate the feed by passing the list of users,
    # and then we publish the event across all of the corresponding feeds.
    @feed = ActiveFeed::FriendsNews.for(users)
    # And then we publish the event to each feed:
    @feed.publish(sort: Time.now, event: event)
```

Instead of passing the list of user IDs, you can pass an `ActiveRecord::Relation`, 
or a block — which should yield the next element in the array when called,
or nil when exhausted.

For any object types besides Integer, ActiveFeed will call a method
`#to_af` on the object, in order to receive a string representation of
that object.

```ruby
    # This is just an example of how you could return AREL statement
    # which can then be fetched in groups (pages) of users and split into
    # several parallel jobs by ActiveFeed.
    
    @follower = User.where(follower: @event.actor)
    @feed = ActiveFeed.of(:followers_feed).for(@follower)
    @feed.publish(event: @event, sort: Time.now) # publish the event sorted by time.
```

##### Writing Efficiently, and/or Concurrently

For large data sets it is generally required to use batch operations, instead of looping for each user. If you are using Rails, then the corresponding method of interest is `#find_in_batches`, which can apply to any `ActiveRecord::Relation` instance. This method retrieves a batch of records and then yields the entire batch to the block as an array of models.

If you are not using Rails, you can still use any custom method that yields batches, one by one, to the block, where each batch can be as an array of integers or models.

```ruby
    @feed = ActiveFeed.of(:news_feed).for do
      User.where(followee: @event.actor)
          .find_in_batches(batch_size: 1000) { |users| yield(users) }
    end
    
    # Now the #publish method can batch pushing the event to the users, 
    # possibly in parallel as a possible optimization.
    @feed.publish(event: @event)
```

#### Reading the Feed Using `#paginate` and `#find_in_batches`

```ruby
  require 'activefeed'

  # You can also use just #reader method, instead of #create_reader
  @feed = ActiveFeed.of(:news_feed).for(User.where(username: 'kig').first)  
  @feed.paginate(page: 1, per_page: 20)  
  # => [ <Events::FavoriteCommentEvent#0x2134afa user: ..., comment: ...>, <Events::StoryPostedEvent...>]
```

OR You can also use another method `#find_in_batches`, which is meant to emulate similar method available in Rails framework. The method can be configured with different batch size, and yields a up to max events to the block defined.

```ruby
  @feed.find_in_batches(batch_size: 100) do |events|
    # do something with the list of events for this batch.
  end
end
```

#### Rendering a Single Page 

To actually render/display the feed to the user, we can _render_ each element (or event) returned by the `#paginate` call:

```ruby
  json = @feed.paginate(page: 1, per_page: 20).map do |event|
    event.render(:json)                                    
    # => { "name": "FavoriteComment", "user": { "username": "kig" }, .... }"
  end.join(', ')
```

### Installation

Add this line to your application's Gemfile:

```ruby
    gem 'activefeed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activefeed


### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/activefeed

### License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

### Acknowledgements

 * This project is conceived and sponsored by [Simbi, Inc.](https://simbi.com).
 * Author's personal experience at [Wanelo, Inc.](https://wanelo.com) has served as an inspiration.

 
