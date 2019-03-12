## Reversi with Optimizely

https://www.optimizely.com/

### A/B experiments

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

### Feature Flags

__Optimizely before Reversi__

```swift
let enabled = optimizelyClient?.isFeatureEnabled("price_filter", userId: userId)
if enabled {
    myObject.variation()
} else {
    myObject.defaultVariant()
}
```

__Optimizely with Reversi__

```swift
myObject.defaultVariant()
myObject.addFeatureFlag("price_filter") { object in
    object.variation()
}
```

## How to expose Firebase to Reversi

Reversi can support feature flags and A/B testing from Optimizely. _However Optimizely supports feature flag variable as well, but Reversi doesn't at the moment._ 🏗

```swift
func canExecute<T>(_ variation: Variation<T>) -> Bool {
    guard let optimizelyClient = optimizelyClient else {
        return false
    }

    if variation.type == .featureFlag {
        return optimizelyClient.isFeatureEnabled(variation.key, userId: userId)
    }

    return optimizelyClient.activate(variation.key, userId: userId) != nil
}

func execute<T>(_ variation: Variation<T>, options: [String : Any]?) {

    switch variation.type {
    case .featureFlag:

        // feature flag only support Void
        if let variation = variation as? Variation<Void> {
            variation.execute(with: ())
            return
        }

    case .variant:

        if let variation = variation as? Variation<Void>,
            let variableKey = options?["variable_key"] as? String,
            let optimizelyVariation = optimizelyClient?.variation(variation.key, userId: userId),
            optimizelyVariation.variationKey == variableKey {
            variation.execute(with: ())
                return
        }
    }
}
```
