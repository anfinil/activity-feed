# ActiveFeed — _Key Features_ 


> [Overview, Usage and Installation](https://github.com/kigster/activefeed/blob/master/README.md)

> [Design](https://github.com/kigster/activefeed/blob/master/DESIGN.md)

> [Serialization and De-Serialization](https://github.com/kigster/activefeed/blob/master/SERIALIZATION.md)

> **[Key Features](https://github.com/kigster/activefeed/blob/master/FEATURES.md)**


The folhttps://github.com/kigster/activefeed/blob/master/SERIALIZATION.md of features that are lated for v1.0:

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
