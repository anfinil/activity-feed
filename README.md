# ActiveFeed

This gem implements a very fast Redis-backed user activity feed of various events relevant to the given user. As events arrive, they are converted to a compacted string-based schema, and stored in several sets within Redis, using several data structures, such as Ordered Set and List. 

This is a "write-time" activity-feed implementation, where the speed optimization is focused on read-time performance, and the majority of the work is done during the "write-time", ie. when the event actually happens. 

When the user requests their feed, it is very easy to populate with a pre-constructed items generated based on the data in Redis, stored for this user.

Key features of this gem are:

 * Very fast, constant time read operation per a given user
 * Compatibility with `twemproxy` and data sharding by user
 * Read and unread items, ability to get the unread item count.
 * 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_feed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_feed

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/active_feed.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

