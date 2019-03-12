## Reversi with Firebase iOS

https://firebase.google.com/docs/ios/setup

### A/B experiments

🏗 Work in progress 🏗

Firebase A/B testing is still in Beta, so does Reversi.

### Feature Flags

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

It looks more complex but the second block looks a bit more clear. You know which implementation is default and the part that relies on variation.

## How to expose Firebase to Reversi

Reversi can support feature flags through RemoteConfig from Firebase.

```
func canExecute<T>(_ variation: Variation<T>) -> Bool {
    // careful here, default config can kicks in if remote isn't fetch yet
    // make sure of your default config to use it that way
    return remoteConfig[variation.key].boolValue
}

func execute<T>(_ variation: Variation<T>, options: [String : Any]?) {

    // detect Void type
    if let variation = variation as? Variation<Void> {
        variation.execute(with: ())
        return
    }

    // Bool type
    if let variation = variation as? Variation<Bool> {
        let value = remoteConfig[variation.key].boolValue
        variation.execute(with: value)
        return
    }

    // String type
    if let variation = variation as? Variation<String>,
        let value = remoteConfig[variation.key].stringValue {
        variation.execute(with: value)
        return
    }

    // Int type
    if let variation = variation as? Variation<Int>,
        let value = remoteConfig[variation.key].numberValue?.intValue {
        variation.execute(with: value)
        return
    }
    ...
}
```
