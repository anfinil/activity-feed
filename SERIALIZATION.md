# ActiveFeed — _Serialization & De-Serialization_ 

> [Overview, Usage and Installation](README.md)

> [Design](DESIGN.md)

> **[Serialization and De-Serialization](SERIALIZATION.md)**

> [Key Features](FEATURES.md)

### Events 

In order for the activity feed data store to remain of a manageable size (in terms of operating RAM), you have two levers to tweak:

 1. How many items can be stored in each individual user's feed, and
 2. How big is each individual activity feed event as it's stored in the feed's backend.

While #1 is typically defined by the Product, #2 is not user-facing, and is something you should try to compact as much as possible (especially if you anticipate lots of users, eg. millions). 

You could use a JSON or YAML representation of a small value object, or even a result of `Marshall.dump`. What worked for the authors in the past is using a delimited structure. Below we'll walk through an example of how events could be defined in the application, and how we can serialize each event into a short string.


### An Example 

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

### Implementing Serialization

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

#### Rails and ActiveRecord Models

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
