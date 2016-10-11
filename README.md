# dehub

## Synopsis

dehub is an app that can be used to view your gists and to create new gists.
It is written using RxSwift using a MVP-like architecture.

## Setup (requires Xcode 8.0/Swift 3 or greater)

* Install [Carthage](https://github.com/Carthage/Carthage)
* Clone the repo and run ```carthage bootstrap --platform iOS```
* Open in Xcode and you are good to go

# Architecture

The app is split into two frameworks, one called ```Model``` and the other called ```View```.
```Model``` is responsible for fetching data from the network and updating the state of the application.
```View``` is responsible for displaying the state on the screen and handling user interaction.

## The View

The view layer architecure is inspired by Srdan Rasic's blog post 
[A Different Take on MVVM with Swift](http://rasic.info/a-different-take-on-mvvm-with-swift/) with some significant changes.

In this architecture, each screen in the app has a ```Scene```, ```Stage``` and ```Director``` object,
which together fulfill the same role as the UIViewController in a vanilla iOS app.

### The ```Stage```

Is responsible for rendering the views (labels, buttons etc) and responding to user input.
The ```Stage``` is "dumb" in that it does not have any business logic.
It doesn't perform any network calls, IO, or updates any state.
It doesn't even know what it "means" when the user taps a button, it just delegates this event to the ```Director```.

### The ```Director```

Tells the ```Stage``` what to do. For example a ```Director``` may call a method ```enableLoginButton(enabled: Bool)``` on its ```Stage```. The ```Stage``` would then enable or disable the login button in this method. The important concept here is that only the ```Director``` contains the logic that decides when and with what argument the ```enableLoginButton(enabled: Bool)``` method should be called.

Let's say that the ```enableLoginButton(enabled: Bool)``` should be called with ```true``` if the user has entered some text in both the username field and the password field. Since the fields are views, they are referenced by the ```Stage```, and since the ```Director``` needs to know their values, the ```Stage``` has to send their values to the ```Director```.

```[Stage] --> [username] --> [Director]```

```[Stage] --> [password] --> [Director]```

The ```Director``` can then do
```swift
let enabled = !username.isEmpty && !password.isEmpty
stage.enableLoginButton(enabled: enabled)
```

The ```Director``` communicates with the stage by directly calling methods on it, while the ```Stage``` communicates with the ```Director``` by exposing RxSwift properties that the ```Director``` observes.

### The ```Scene```

Creates the ```Stage``` and the ```Director``` and is responsible for transitioning to other scenes. Generally a ```Director``` calls a method on a ```Scene``` when it decides that the scene should change. The ```Scene``` then performs the transition to the new ```Scene```, which creates it's corresponding ```Director``` and ```Stage```.

## Bootstrapping

When the app starts it creates the initial ```Scene``` which in turn creates the initial ```Stage``` and ```Director```.

