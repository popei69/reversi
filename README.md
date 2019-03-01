# Reversi ⚫️⚪️

[![CI Status](https://img.shields.io/travis/popei69/Reversi.svg?style=flat)](https://travis-ci.org/popei69/Reversi)
[![Version](https://img.shields.io/cocoapods/v/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)
[![License](https://img.shields.io/cocoapods/l/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)
[![Platform](https://img.shields.io/cocoapods/p/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)

Reversi ⚫️⚪️ is an A/B testing framework written in Swift.

🏗 Work in progress 🏗

## What is my goal with Reversi

* Feature flags and A/B testing tools are designed for Product Marketers and Managers and forgot to be _developer friendly_. Adding A/B testing or feature flag should be as easy as setting up any properties.
* Choose your service, keep your data. Reversi doesn't handle data, it should be designed to work with bundled file as well as remote services. You'll only inject your experiments at launch, Reversi will handle the display.

## How does it work?

Reversi includes variations and will execute only the one included in the running experiments.
The key designed the unique identifier to that experiment.

```swift
label.text = "Hello World"
label.font = UIFont.boldSystemFont(ofSize: 15)
label.textColor = .darkGray

label.addVariation("text_variation") { label in
    label.text = "Variation World"
}
```

There is no limit to the number of variations and their access

```swift
label
    .addVariation("text_variation") { label in
        label.text = "Variation World"
    }
    .addVariation("text_variation") { label in
        label.font = UIFont.boldSystemFont(ofSize: 14)
    }

// button color
button.addVariation("button_variation") { $0.backgroundColor = .orange }

// combined elements
self.addVariation("combined_variation") { viewController in
    viewController.label.textColor = .lightGray
    viewController.button.setTitleColor(.lightGray, for: .normal)
}
```

Since each experiment directly affects UI elements, varations are only executed on main thread.

## TODO

- [ ] Create a configuration file for bundled experiments
- [ ] Ability to support variation in value: text color, image url, etc.
- [ ] Ability to support remote configuration
- [ ] Ability to support amount of users affected per experiment

## Installation

Reversi is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Reversi'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Benoit Pasquier, b.pasquier69@gmail.com

## License

Reversi is available under the MIT license. See the LICENSE file for more info.
