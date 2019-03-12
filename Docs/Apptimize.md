## Reversi with Apptimize

Apptimize is a popular tool used for feature flag and A/B experiments.
It can be couple with Reversi to keep a clean code and abstract your code to avoid depending of their synthax or tools.

### A/B experiments

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
self.addVariation("variation1", for: Void.self, options: ["test_name": "Add GuestFlow"]) { viewController, _ in
    // Variant "Guest Flow"
    viewController._loginWithGuestButton.isHidden  = true
    viewController.useGuestFlow.hidden = true
}
```

### Feature Flags

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
myObject.addFeatureFlag("new_feature_flag_variable"{ object in
    object.customVariant()
}
```

### How to expose Apptimze to Reversi

Reversi can support feature flags and A/B testing from Apptimize, we only need to expose its functions through the configuration.

```swift
func canExecute<T>(_ variation: Variation<T>) -> Bool {
    switch variation.type {
    case .featureFlag:
        return Apptimize.isFeatureFlag(on: variation.key)
    default:
        return true
    }
}

public func execute<T>(_ variation: Variation<T>, options: [String: Any]?) {

    switch variation.type {
    case .featureFlag:

        // detect Void type
        if let variation = variation as? Variation<Void> {
            variation.execute(with: ())
            return
        }

    case .variant:

        guard let variation = variation as? Variation<Void>,
            let testName = options?["test_name"] as? String
            else {
            return
        }

        let codeblock = ApptimizeCodeBlock(name: variation.key) {
            variation.execute(with: ())
        }
        Apptimize.runTest(testName, withBaseline: {
            // baseline should be your code by default
        }, andApptimizeCodeBlocks: [codeblock])
    }
}
```

Check [ApptimizeConfiguration.swift](https://github.com/popei69/reversi/blob/master/Example/Reversi/ApptimizeConfiguration.swift) file to see a complete example.
