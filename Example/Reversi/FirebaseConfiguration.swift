//
//  FirebaseConfiguration.swift
//  Reversi_Example
//
//  Created by Benoit PASQUIER on 12/03/2019.
//  Copyright © 2019 Benoit PASQUIER. All rights reserved.
//

import Foundation
import Reversi
import Firebase

final class FirebaseConfiguration : ReversiConfigurationProtocol {
    
    var remoteConfig: RemoteConfig!
    
    func setup() {
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)
        
        // TimeInterval is set to expirationDuration here, indicating the next fetch request will use
        // data fetched from the Remote Config service, rather than cached parameter values, if cached
        // parameter values are more than expirationDuration seconds old. See Best Practices in the
        // README for more information.
        remoteConfig.fetch(withExpirationDuration: TimeInterval(10)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    func canExecute<T>(_ variation: Variation<T>) -> Bool {
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
    }
    
    
}
