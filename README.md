# Reversi ⚫️⚪️

[![CI Status](https://img.shields.io/travis/popei69/Reversi.svg?style=flat)](https://travis-ci.org/popei69/Reversi)
[![Version](https://img.shields.io/cocoapods/v/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)
[![License](https://img.shields.io/cocoapods/l/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)
[![Platform](https://img.shields.io/cocoapods/p/Reversi.svg?style=flat)](https://cocoapods.org/pods/Reversi)

Reversi ⚫️⚪️ is an A/B testing framework written in Swift.

🏗 Work in progress 🏗

## Content

 - [The goal of Reversi](#the-goal-of-reversi)
 - [Why Reversi?](#why-reversi-)
 - [How does it work?](#how-does-it-work-)
 - [Usage](#usage)
 - [Installation](#installation)
 - [Example](#example)
 - [Installation](#installation)
 - [State of the project](#state-of-the-project)


## The goal of Reversi

* Feature flags and A/B testing tools are designed for Product Marketers and Managers and forgot to be _developer friendly_. Adding A/B testing or feature flag should be as easy as setting up any properties.
* Choose your service, keep your data. Reversi doesn't handle data, it should be designed to work with bundled file as well as remote services. You'll only inject your experiments at launch, Reversi will handle the display.

## Why Reversi?

Adding A/B testing or feature flag should be as easy as setting up any properties.

__Apptimize before Reversi__
```swift
Apptimize.runTest("Add GuestFlow", withBaseline: { () -> Void in
    // Baseline variant "original"
    _loginWithGuestButton.isHidden = false
    useGuestFlow.hidden = false
}, andApptimizeCodeBlocks: [
    ApptimizeCodeBlock(name: "variation1") {
        // Variant "Guest Flow"
        _loginWithGuestButton.isHidden  = true
        useGuestFlow.hidden = true
    }]
)
```

__Apptimize with Reversi__

```swift
// default setup
_loginWithGuestButton.isHidden = false
useGuestFlow.hidden = false

// adding variation
self.addVariation("variation1", ofType: Void.self) { viewController, _ in
    // Variant "Guest Flow"
    _loginWithGuestButton.isHidden  = true
    useGuestFlow.hidden = true
}
```


## How does it work?

Reversi includes variations and will execute only the one included in the running experiments.
The key designed the unique identifier to that experiment.

```swift
// imagine local or remote configuration
let config = [["key": "text_variation", "value": "Hello Variation World"], ...]
ReversiService.shared.configure(with: config)

label.text = "Hello World"
label.font = UIFont.boldSystemFont(ofSize: 15)
label.textColor = .darkGray

// will be executed only if "text_variation" experiment is up and running
label.addVariation("text_variation", ofType: String.self) { label, value in
    label.text = value // "Hello Variation World"
}
```

## Usage

There is no limit to the number of variations and their access

```swift
label
    .addVariation("text_variation", ofType: String.self) { label, variationText in
        label.text = variationText
    }
    .addVariation("text_variation", ofType: Void.self) { label, _ in
        label.font = UIFont.boldSystemFont(ofSize: 14)
    }

// button color
button.addVariation("button_variation", ofType: Void.self) { button, _ in
    button.backgroundColor = .orange
}

// combined elements
self.addVariation("combined_variation", ofType: Void.self) { viewController, _ in
    viewController.label.textColor = .lightGray
    viewController.button.setTitleColor(.lightGray, for: .normal)
}
```

Since each experiment directly affects UI elements, varations are only executed on main thread.

## Installation

Reversi is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Reversi'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## State of the project

- [ ] Create a configuration file for bundled experiments
- [ ] Ability to support variation in value: Bool, Int, String, etc.
- [ ] Ability to support remote configuration
- [ ] Ability to support amount of users affected per experiment

## Author

Benoit Pasquier, b.pasquier69@gmail.com

## License

Reversi is available under the MIT license. See the LICENSE file for more info.
