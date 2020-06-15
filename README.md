# Reversi ⚫️⚪️

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![CI Status](https://img.shields.io/travis/popei69/reversi.svg?style=flat)](https://travis-ci.org/popei69/reversi)
[![Version](https://img.shields.io/cocoapods/v/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)
[![Swift Package Manager compatible](https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)

Reversi ⚫️⚪️ is an A/B testing framework written in Swift.

Read more about the motivation on [my blog](https://benoitpasquier.com/reversi-ab-testing-framework-ios/).

## Content

 - [Why Reversi?](#why-reversi)
    - [Apptimize case study](#apptimize)
    - [Firebase case study](#firebase)
    - [Optimizely case study](#optimizely)
 - [How does it work?](#how-does-it-work)
 - [Usage](#usage)
 - [Installation](#installation)
 - [Example](#example)
 - [Installation](#installation)
 - [State of the project](#state-of-the-project)
 - [Contributing](#contribute)


## Why Reversi?

* Feature flags and A/B testing tools are designed for Product Marketers and Managers and forgot to be _developer friendly_. Adding A/B testing or feature flag should be as easy as setting up any properties.
* Choose your service, keep your data. Reversi doesn't handle data, it should be designed to work with bundled file as well as remote services. You'll only inject your configuration at launch, Reversi will handle when to run UI variations.

### Apptimize
__Apptimize before Reversi__
```swift
if (Apptimize.isFeatureFlagOn("new_feature_flag_variable")) {
   // ON
   myObject.customVariant()
} else {
   // OFF
   myObject.defaultVariant()
}
```

__Apptimize with Reversi__

```swift
myObject.defaultVariant()
myObject.addFeatureFlag("new_feature_flag_variable") { object in
    object.customVariant()
}
```

Read more about how to implement [Reversi for Apptimze](/Docs/Apptimize.md)

### Firebase
__Firebase before Reversi__
```swift
var welcomeMessage = remoteConfig[welcomeMessageConfigKey].stringValue
```

__Firebase with Reversi__

```swift
var welcomeMessage = "Welcome"
welcomeMessage.addVariation(welcomeMessageConfigKey, for: String.self) { welcomeMessage, newText in
    welcomeMessage = newText
}
```

Read more about how to implement [Reversi for Firebase](/Docs/Firebase.md)

### Optimizely
__Optimizely before Reversi__
```swift
// Activate an A/B test
let variation = client?.activate("app_redesign", userId:"12122")
if (variation?.variationKey == "control") {
    // Execute code for "control" variation
    myObject.variantControl()
} else if (variation?.variationKey == "treatment") {
    // Execute code for "treatment" variation
    myObject.variantTreatment()
} else {
    // Execute code for users who don't qualify for the experiment
    myObject.defaultVariant()
}
```

__Optimizely with Reversi__

```swift
// Activate an A/B test
myObject.defaultVariant()
myObject
    .addVariation("app_redesign", for: Void.self, options: ["variable_key": "control"]) { myObject, _ in
        myObject.variantControl()
    }
    .addVariation("app_redesign", for: Void.self, options: ["variable_key": "treatment"]) { myObject, _ in
        myObject.variantControl()
    }
```

Read more about how to implement [Reversi for Optimizely](/Docs/Optimizely.md)

## How does it work?

Reversi includes variations and will execute only the one included in the running experiments.
The key designed the unique identifier to that experiment.

```swift
// feed your configuration to the service from local json or remote service
ReversiService.shared.configure(with: configuration)

label.text = "Hello World"
label.font = UIFont.boldSystemFont(ofSize: 15)
label.textColor = .darkGray

// block will be executed only if "text_variation" experiment is up and running
label.addVariation("text_variation", for: String.self) { label, value in
    label.text = value // "Hello Variation World"
}
```

## Usage

There is no limit to the number of variations and their access

```swift
label.addVariation("text_variation", for: String.self) { label, value in
    label.text = variationText
}
.addFeatureFlag("font_variation") { label in
    label.font = UIFont.boldSystemFont(ofSize: 14)
}

// button color
button.addFeatureFlag("button_variation") { button in
    button.backgroundColor = .orange
}

// combined elements
self.addFeatureFlag("combined_variation") { viewController in
    viewController.label.textColor = .lightGray
    viewController.button.setTitleColor(.lightGray, for: .normal)
}
```

Since each experiment directly affects UI elements, variations are only executed on main thread.

## Installation

### Swift Package Manager

```
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/popei69/reversi.git", from: "1.1.0")
    ],
    ...
)
```

### CocoaPods

Reversi is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Reversi'
```

### Carthage

Reversi is also available through Carthage.

```
github 'popei69/Reversi' ~> 1.0
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## State of the project

- [x] Create a configuration file for bundled experiments
- [x] Ability to support variation in value: Void, Bool, Int, String.
- [x] Ability to support remote configuration: Apptimize, Firebase, Optimizely.
- [x] Unit tests for stability.
- [ ] Ability to support amount of users affected per experiment

## Author

Benoit Pasquier, b.pasquier69@gmail.com

## Contributing

This project is still exploratory. I'm happy for anybody to create an issue for suggestions and improvements.

## License

Reversi is available under the MIT license. See the LICENSE file for more info.
