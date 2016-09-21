# dehub

## Synopsis

dehub is an app that can be used to view your gists and to create new gists.
It is written using RxSwift using a MVP-like architecture.

## Setup

* Install [Carthage](https://github.com/Carthage/Carthage)
* Clone the repo and run ```carthage bootstrap --platform iOS```
* Open in Xcode and you are good to go

# Architecture

The app is split into two frameworks, one called ```Model``` and the other called ```View```.
```Model``` is responsible for fetching data from the network and updating the state of the application.
```View``` is responsible for displaying the state on the screen and handling user interaction.

## The View

The view layer architecure is based on Srdan Rasic's blog post 
[A Different Take on MVVM with Swift](http://rasic.info/a-different-take-on-mvvm-with-swift/)

In this setup, each screen in the app has a ```Scene```, ```Stage``` and ```Director``` object,
which together fulfill the same role as the UIViewController in a vanilla iOS app.

### The ```Stage```

Is responsible for rendering the views (labels, buttons etc) and responding to user input.
The ```Stage``` is "dumb" in that it does not have any business logic.
It doesn't perform any network calls, IO, or updates any state.
It doesn't even know what it "means" when the user taps a button, it just delegates this event to the ```Director```.

### The ```Director```

Tells the ```Stage``` what to do. For example a ```Director``` may have a property called ```enableLoginButton```.
The ```Stage``` would then listen to this property, and depending on whether it is true or false it would enable or disable
the login button. The important concept here is that only the ```Director``` contains the logic that decides
if ```enableLoginButton``` should be true or false.

Let's say that the ```enableLoginButton``` should be true if the user has entered some text in both the
username field and the password field. Since the fields are views, they are referenced by the ```Stage```, and since
the ```Director``` needs to know their values, the ```Stage``` has to send their values to the ```Director```.

```[Stage] --> [username] --> [Director]```

```[Stage] --> [password] --> [Director]```

The ```Director``` can then set ```enableLoginButton = !username.isEmpty && !password.isEmpty```
and send that back to the ```Stage```:

```[Stage] <-- [enableLoginButton] <-- [Director]```

### The ```Scene```

Creates the ```Stage``` and the ```Director``` and is responsible for transitioning to other scenes.



