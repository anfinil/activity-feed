# ActiveFeed — _Design_ 


> [Overview, Usage and Installation](https://github.com/kigster/activefeed/blob/master/README.md)

> **[Design](https://github.com/kigster/activefeed/blob/master/DESIGN.md)**

> [Serialization and De-Serialization](https://github.com/kigster/activefeed/blob/master/SERIALIZATION.md)

> [Key Features](https://github.com/kigster/activefeed/blob/master/FEATURES.md)


### How a Feed Works

A typical activity feed works as follows:
``
1. user (_an actor_) makes an action that should appear in the feeds of other users, typically actor's followers
2. An activity _event_ is dispatched by the application that contains everything needed to render this event in the newsfeed later, including the _actor_, the _action_, the _action's target_, and perhaps some additional metadata.
3. The event necessarily maps onto an _audience_ — users who should see it in their feeds
4. Event is then _serialized_ into a compact scalar format, and pushed to the user's feed, where the feed can be represented by a fixed-length array, containing the last N activities, most recent first.
5. Older activities are pushed out of the array as new ones come in, and are discarded.
6. Since activities in the feed are sorted by the time when each event occurred, but they could be re-arranged or aggregated via a separate process, or during the read time by the rendering engine.

Because of some of the above reasons, this feed works best in combination with an application eventing frameworks, such as [Ventable](https://github.com/kigster/ventable), or [Wisper](https://github.com/krisleech/wisper).  

### UML

Below is the high-level UML diagram that shows how the internals of the active feed work:

[![UML](https://raw.githubusercontent.com/kigster/activefeed/master/uml/active-feed-uml.png)](https://raw.githubusercontent.com/kigster/activefeed/master/doc/active-feed-uml.png)

### Write-Time versus Read-Time Feeds

This is a _write-time_ activity-feed implementation, where the speed optimization is focused on the _read-time_ performance, and the majority of the work is performed when the event is actually published. When the user requests their feed, it is constructed by returning the rendered versions of the events stored in the user's feed. Because the feed is pre-computed at write time, the rendering phase is very fast, making users happy with a snappy news feed.

#### Speed vs Real-time Trade-Off

The trade-off here is a possible delay in receiving an event in your feed. Because most of the work is performed at the event generation time, it must update feeds of all users who are subscribed to (or follow) a user (or any other model) that generated the event. If your system allows large audiences (eg, Twitter's celebrities have many millions of followers), then this approach suffers from a 'Bieber Problem'. For more information on the differences between _write-time_ and _read-time_ activity feed, please read [the following blog post by Lee Byron, Facebook](https://hashnode.com/post/architecture-how-would-you-go-about-building-an-activity-feed-like-facebook-cioe6ea7q017aru53phul68t1/answer/ciol0lbaa02q52s530vfqea0t)

Events can be a pure ruby classes, as long as they respond to the required methods (see below). They should also be able to render themselves in whatever formats needed, in order to show up within the application, but this functionality is outside of the scope of this gem.
