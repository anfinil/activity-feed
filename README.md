# ActiveFeed

This gem implements a very fast Redis-backed user activity feed of various events relevant to the given user. As events arrive, they are converted to a compacted string-based schema, and stored in several sets within Redis, using several data structures, such as Ordered Set and List. 

This is a "write-time" activity-feed implementation, where the speed optimization is focused on read-time performance, and the majority of the work is done during the "write-time", ie. when the event actually happens. 

When the user requests their feed, it is very easy to populate with a pre-constructed items generated based on the data in Redis, stored for this user.

Key features of this gem are (for a Redis backend):

 * Very fast, constant time read operation for any user
 * Compatibility with `twemproxy` and data sharding by user ID to support massive data sets
 * Total, read and unread items count for any user
 * Remove items from other user's existing feeds (ie, when someone unfollows) 

It is my hope to keep this gem small and very targeted to solving a specific problem: reading and writing from an abstracted backend that can later be replaced with another underlying solution if needed.
 
## Usage

First you need to configure the Feed with a valid backend implementation, and configure it.

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

Above awe've configured both the Redis client, and passed it to the `ActiveFeed::Backend::Redis` – which is
an implementation of the backend data store.

### Writing Data to the Feed
 
```ruby
  # Given @event (containing :actor, :object, :target, etc) and the list of users to 
  # update with this event, this is how we add it to the feed:
  require 'active_feed/writer'
  user_id_list = [1,4,545, 234234]
  ActiveFeed::Writer.new(user_id_list).add(sort: Time.now, value: @event.feed_value)
```

Note the events must implement `#feed_value` method, which would return a short representation of the event, sufficient to render the event in JSON or HTML later. For example, this would probably be a short delimited string, with a type and a few IDs identifying the value.
 
### Reading Data from the Feed

Given a user,

```ruby
  require 'active_feed/reader'

  reader = ActiveFeed::Reader.new(@user)
  reader.paginate(page: 1).map do |item|
    # item here is a string, of the form, eg: 'l:23145:434243:343425', where l = like
    # and the three numbers are ids of actor, object and the object's target.
    
    NewsFeedItem.restore(item)    # returns +UserLikedAStoryItem+ instance
      .render(:json)              # returns JSON string representation of the news feed item
         
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

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/active_feed.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

