# dehub-ios

## Synopsis

DeHub is a sample app that can be used to view your gists and to create new gists.
It is written using a MVVM architecture based on RxSwift.

## Setup (requires Xcode 8.3 or greater)

* Install [Carthage](https://github.com/Carthage/Carthage)
* Clone the repo and run ```carthage bootstrap --platform iOS --no-use-binaries```
* Open in Xcode and you are good to go

Note: if you get a build error complaining about a missing module ``Model``, change the target to ``Model`` and build it first first.

# Architecture

Coming soon

# Main libraries used

##[RxSwift](https://github.com/ReactiveX/RxSwift)##

Used for observing the the view state.

__Learning resources:__
RxSwift has the same fundamental API as RxJava, so RxJava resources can be used for learning the concepts:
* [Grokking RxJava](http://blog.danlew.net/2014/09/15/grokking-rxjava-part-1/) - A good place to start learning.
* [Common RxJava Mistakes](https://www.youtube.com/watch?v=QdmkXL7XikQ)
* [Reactive Programming with RxJava](http://shop.oreilly.com/product/0636920042228.do) - A good in-depth book on RxJava.

For RxSwift specifics, see the [documentation](https://github.com/ReactiveX/RxSwift/tree/master/Documentation).
