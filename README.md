### WARNING: this project is under active development, and is not yet finished.

[![Gem Version](https://badge.fury.io/rb/active_feed.svg)](http://rubygems.org/gems/active_feed)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/kigster/activefeed/master/LICENSE.txt)

[![Build Status](https://travis-ci.org/kigster/activefeed.svg?branch=master)](https://travis-ci.org/kigster/activefeed)
[![Code Climate](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/gpa.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/feed)
[![Test Coverage](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/coverage.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/coverage)
[![Issue Count](https://codeclimate.com/repos/5813da0398926c0088000285/badges/5e15f53bfbcd4c68cdaa/issue_count.svg)](https://codeclimate.com/repos/5813da0398926c0088000285/feed)

# ActiveFeed

> **A fast and scalable "write-time" activity feed for Social Networks, with a Redis-based default backend implementation**. 
> 
> This project is sponsored by [Simbi, Inc.](https://simbi.com)

## What's an Activity Feed?

Here is a typical text-based activity feed that is so common today on social networks:

[![Example](https://raw.githubusercontent.com/kigster/activefeed/master/doc/active-feed-example.png)](https://raw.githubusercontent.com/kigster/activefeed/master/doc/active-feed-example.png)


## Overview

This is a "from-the-ground-up" written library that implements the concept of an activity feed, and hopes to address the following goals:

 * To define a minimalistic API for a typical event-based activity feed, without tying it to any concrete backend
 * To make it easy to implement and plug in a new type of backend, eg. using Couchbase or MongoDB 
 * To provide a scalable default backend implementation using Redis, which can support millions of users via sharding 
 * To support multiple activity feeds within the same application, but used for different purposes, eg. activity feed of my followers, versus activity feed of my own actions.

### Key Features

The following is a list of features that are currently slated for v1.0:

1. **Updating the activity feed** is generally done for a set of users. Typical example being an event distributed to all followers of the person generating the event (ie. "actor"). Here we support:

    * _Publishing_ a new event to related users
    * _Deleting_ an event from all related user feeds
    * _Aggregating_ similar events within each user's feed (not planned for v1.0)
    * _Related users_ are definable in terms of an Array, Enumeration or an `ActiveRecord::Relation`, where using `#find_in_batches` is the recommended approach for performance.
    
2. **Reading the feed** is typically done for a given user — the user accessing their application feed. The library provides support for:

    * _Quickly fetching the number of unread activities_ in the user's feed, eg. for the purpose of display the alert badge on the icon.
    * _Fetching and paginating_ events, eg. for the purpose of rendering them on the UI
    * _Resetting the last viewing time_ for a given user, so that number of unread activities is reset to 0.

3. **Scaling the feed** is done by focusing on high performance in the feed design. and data sharding across many instances, to allow parallel independent queries for concurrent users:

    * _Constant time, fast read operations_ on the news feed due to it's pre-computed design, and hash-based storage
    * _Ability to shard_ data across many servers, and many instances of Redis, by leveraging one or more [`twemproxies`](https://github.com/twitter/twemproxy). Twemproxy can be used to configure sharding, and using sharding **ActiveFeed** can be used to support massive data sets across any number of servers

It is my hope to keep this gem small and very targeted to solving a specific problem, which is **to define a basic activity feed API for reading and writing from/to a backend which can be swapped out with another implementation, and to offer a reference implementation using Redis, as well as the direction for scaling the feed.**

## Design

### How a Feed Works

A typical activity feed works as follows:

1. user (_an actor_) makes an action that should appear in the feeds of other users, typically actor's followers
2. An activity _event_ is dispatched by the application that contains everything needed to render this event in the newsfeed later, including the _actor_, the _action_, the _action's target_, and perhaps some additional metadata.
3. The event necessarily maps onto an _audience_ — users who should see it in their feeds
4. Event is then _serialized_ into a compact scalar format, and pushed to the user's feed, where the feed can be represented by a fixed-length array, containing the last N activities, most recent first.
5. Older activities are pushed out of the array as new ones come in, and are discarded.
6. Since activities in the feed are sorted by the time when each event occurred, but they could be re-arranged or aggregated via a separate process, or during the read time by the rendering engine.

Because of some of the above reasons, this feed works best in combination with an application eventing frameworks, such as [Ventable](https://github.com/kigster/ventable), or [Wisper](https://github.com/krisleech/wisper).  

### UML

Below is the high-level UML diagram that shows how the internals of the active feed work:

[![UML](https://raw.githubusercontent.com/kigster/activefeed/master/doc/active-feed-uml.png)](https://raw.githubusercontent.com/kigster/activefeed/master/doc/active-feed-uml.png)

### Write-Time versus Read-Time Feeds

This is a _write-time_ activity-feed implementation, where the speed optimization is focused on the _read-time_ performance, and the majority of the work is performed when the event is actually published. When the user requests their feed, it is constructed by returning the rendered versions of the events stored in the user's feed. Because the feed is pre-computed at write time, the rendering phase is very fast, making users happy with a snappy news feed.

#### Speed vs Real-time Trade-Off

The trade-off here is a possible delay in receiving an event in your feed. Because most of the work is performed at the event generation time, it must update feeds of all users who are subscribed to (or follow) a user (or any other model) that generated the event. If your system allows large audiences (eg, Twitter's celebrities have many millions of followers), then this approach suffers from a 'Bieber Problem'. For more information on the differences between _write-time_ and _read-time_ activity feed, please read [the following blog post by Lee Byron, Facebook](https://hashnode.com/post/architecture-how-would-you-go-about-building-an-activity-feed-like-facebook-cioe6ea7q017aru53phul68t1/answer/ciol0lbaa02q52s530vfqea0t)

Events can be a pure ruby classes, as long as they respond to the required methods (see below). They should also be able to render themselves in whatever formats needed, in order to show up within the application, but this functionality is outside of the scope of this gem.

## Usage

First you need to configure the Feed with a valid backend implementation.

### Configuration

```ruby
    require 'activefeed'
    require 'redis'
      
    ActiveFeed.configure do |config|
      config.of(:friends_news) do |friends_news|
        friends_news.backend      = ActiveFeed::Backend::RedisBackend.new(
          redis: -> { ::Redis.new(host: '127.0.0.1') },
          feed: friends_news
        )
        # how many items can be in the feed
        friends_news.max_size     = 1000
        friends_news.per_page     = 20
            
        # These optional callbacks allow handling activities that are added or removed from the feed.     
        friends_news.on(:push,   ->(user, event) { puts "pushed #{event} to #{user}'s feed'"     })
        friends_news.on(:pop,    ->(user, event) { puts "expired #{event} from #{user}'s feed'"  })
        friends_news.on(:remove, ->(user, event) { puts "removed #{event} from #{user}'s feed'"  })
      end
    end
```

Above we've configured the Redis client, passed the proc that creates new Redis clients into the Redis Backend for `ActiveFeed`. We've also limited the max size of the feed to a 1000 items – which are typically 1000 most recent events.

#### Multiple Independent Activity Feeds

But sometimes a single feed is not enough. What if we wanted to maintain two separate personalized feeds for each user: one would be news articles the user subscribes to, and the other would be a more typical activity feed. 

We can create an additional activity feed, say for followers, and call it `:followers` at the same time, and configure it with a slightly different backend. Because we expect this activity feed to be more taxing – as events might have large audiences — we'll wrap it in the `ConnectionPool` that will create several connections that can be used concurrently:

```ruby
    require 'activefeed'
    require 'redis'
    
    ActiveFeed.configure do |config|
    
      # This is the feed of news articles based on user subscription preferences.
      config.of(:friends_news) do |friends_news| 
        friends_news.backend = ActiveFeed::Backend::RedisBackend.new(
          redis: ::Redis.new(host: '127.0.0.1')
        )
        friends_news.per_page = 20
      end    
    
      # This is the feed of events associated with the followers.
      # We use ConnectionPool because we anticipate higher load.
      config.of(:followers) do |followers_feed| 
        followers_feed.backend = ActiveFeed::Backend::RedisBackend.new(
          redis: ConnectionPool.new(size: 5, timeout: 5) { 
            ::Redis.new(host: '192.168.10.10', port: 9000) 
        })
      end
    end
```

#### Referencing Multiple Feeds

So how do you access the feed from your code? Please check the UML diagram above to see how objects are returned.

When we called `ActivityFeed.of(:friends_news)` for the very first time, the library has created a hash key `:friends_news` that from now on will point to this instance of the feed configuration within the application.
 
```ruby
   ActivityFeed.of(:friends_news) 
   # is the same as 
   ActivityFeed::FriendsNews
```
While
```ruby
   ActivityFeed.of(:followers_feed)
   # is the same as
   ActivityFeed::FollowersFeed
```

### Publishing Data to the Feed

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

#### Writing Efficiently, and/or Concurrently

For large data sets it is generally required to use batch operations, instead of looping for each user. If you are using Rails, then the corresponding method of interest is `#find_in_batches`, which can apply to any `ActiveRecord::Relation` instance. This method retrieves a batch of records and then yields the entire batch to the block as an array of models.

If you are not using Rails, you can still use any custom method that yields batches, one by one, to the block, where each batch can be as an array of integers or models.

```ruby
    @feed = ActiveFeed.of(:news_feed).for do
      User.where(followee: @event.actor)
          .find_in_batches(batch_size: 1000) { |users| yield(users) }
    end
    
    # Now the #publish method can grab users in batches, and push the event, 
    # possibly in parallel as a possible optimization.
    @feed.publish(sort: @event.timestamp, event: @event)
```

### Reading Data from the Feed using #paginate and #find_in_batches

```ruby
  require 'activefeed'

  # You can also use just #reader method, instead of #create_reader
  @feed = ActiveFeed.of(:news_feed).for(User.where(username: 'kig').first)  
  @feed.paginate(page: 1, per_page: 20)  
  # => [ <Events::FavoriteCommentEvent#0x2134afa user: ..., comment: ...>, <Events::StoryPostedEvent...>]
```

OR You can also use another method #find_in_batches, which is meant to emulate similar method available in Rails framework. The method can be configured with different batch size, and yields a up to max events to the block defined.

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

### Event Serialization & De-Serialization

In order for the activity feed data store to remain of a manageable size (in terms of operating RAM), you have two levers to tweak:

 1. How many items can be stored in each individual user's feed, and
 2. How big is each individual activity feed event as it's stored in the feed's backend.

While #1 is typically defined by the Product, #2 is not user-facing, and is something you should try to compact as much as possible (especially if you anticipate lots of users, eg. millions). 

You could use a JSON or YAML representation of a small value object, or even a result of `Marshall.dump`. What worked for the authors in the past is using a delimited structure. Below we'll walk through an example of how events could be defined in the application, and how we can serialize each event into a short string.

#### Example: Delimited Serialization 

Let's start by defining an event we might create in a system to represent somebody liking a comment.

```ruby
@event = NewsFeed::FavoritedTargetEvent.new(
  actor:    current_user,
  action:   'favorited',
  target:   @comment,
  audience: current_user.followers
)
```

In this scheme:

 * _actor_ is the person who generated the event
 * _action_ is a verb in the past tense, eg. "favorited", "liked", "posted", "commented", "followed", etc.
 * _target_ would be the main subject of the action, such as the comment that was favorited
 * _audience_ defines a set of users who should see this update. 

Given the above, we can start by converting the above event into a string like so:

```ruby
@event_serialized = 
  "#{@event.actor.id}-" + 
  "#{@event.verb}-" + 
  "#{@comment.id}"
```

This would produce, eg. a string such as `"12414325-favorited-125646456"`, which is pretty compact-ish. But, as you may notice, it suffers from one problem: it is not possible to definitively tell what each of the numbers refers to.

To solve this, we need to add entity type – some sort of a code that helps us uniquely and unambiguously determine implement the following method on all models in our Rails application. Below we implement method `#to_af` on `User`, which allows us to convert a user instance into a short-string representation `us:99879879`.

### Event Serialization

Events can be pure ruby classes, but they must implement an instance method `#to_af`:

 * `#to_af` instance method, which would return a short representation of the event using a string and IDs related to it. For example, it can be a short delimited string, with a type and a few IDs identifying the event.

Additionally, you must write code that performs the reverse action, and given the serialized version (the result of `to_af`) it de-serializes the data back into the event. This code would then be passed into the initializer for the `Reader` (see below).


```ruby
class User
  #....
  def to_af
    "us:#{self.id}"
  end
end
```

And more generally, we can implement this once globally by reopening the `ActiveRecord::Base` class:

```ruby
class ActiveRecord::Base
  #....
  public:
  def to_af
    my_class_name = self.class.name.split(/::/).last.downcase # => returns 'user'
    "#{my_class_name[0,1]}:#{self.id}}"                       # => returns 'us:1230124324'    
  end
end
```

Now, we can use any model's `#to_af` instance method to construct the event string:
 
```ruby
"#{event.actor.to_af}-#{event.verb}-#{event.target_object.to_af}"
```

which would now generate `"us:12414325-liked-co:125646456-us:2341425453"`

For any given a user, a feed reader can be created by passing a block that, given a serialized version of the event, can deserialize it into a proper application object. For example, if an event of type 'user X favorited comment by user Y', the serialized form of the event (and stored internally) might look like `"#{user_x.to_af}|favorite|#{comment.to_af}|#{comment.user.to_af}"`.  

We can configure both directions: serialization and de-serialization, in the configuration clause of the feed:

```ruby
  # generates eg, 'f-123'
  config[:friends_news].event_serializer   = ->(event) { "#{event.type[0,1]}-#{event.id}" } 
  config[:friends_news].event_deserializer = ->(string) {  
    type, id = string.split(/-/)     
    # ... reconstruct an event from a serialized version'
    EventFactory.from(type).new(id)      
  } 
```

## Installation

Add this line to your application's Gemfile:

```ruby
    gem 'activefeed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activefeed


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/activefeed

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Acknowledgements

 * This project is conceived and sponsored by [Simbi, Inc.](https://simbi.com).
 * Author's personal experience at [Wanelo, Inc.](https://wanelo.com) has served as an inspiration.

 
