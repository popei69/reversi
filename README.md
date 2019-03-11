# Reversi ⚫️⚪️

[![CI Status](https://img.shields.io/travis/popei69/Reversi.svg?style=flat)](https://travis-ci.org/popei69/Reversi)
[![Version](https://img.shields.io/cocoapods/v/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)
[![License](https://img.shields.io/cocoapods/l/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)
[![Platform](https://img.shields.io/cocoapods/p/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)

Reversi ⚫️⚪️ is an A/B testing framework written in Swift.

🏗 Work in progress 🏗

## Content

 - [Why Reversi?](#why-reversi)
    - [Apptimize case study](#apptimize)
 - [How does it work?](#how-does-it-work)
 - [Usage](#usage)
 - [Installation](#installation)
 - [Example](#example)
 - [Installation](#installation)
 - [State of the project](#state-of-the-project)


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

## How does it work?

Reversi includes variations and will execute only the one included in the running experiments.
The key designed the unique identifier to that experiment.

```swift
// feed your configuration to the service
let config = [["key": "text_variation", "value": "Hello Variation World"], ...]
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
label
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

Reversi is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Reversi'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## State of the project

- [x] Create a configuration file for bundled experiments
- [x] Ability to support variation in value: Void, Bool, Int, String.
- [x] Ability to support remote configuration: Apptimize
- [ ] Ability to support amount of users affected per experiment

## Author

Benoit Pasquier, b.pasquier69@gmail.com

## License

Reversi is available under the MIT license. See the LICENSE file for more info.
