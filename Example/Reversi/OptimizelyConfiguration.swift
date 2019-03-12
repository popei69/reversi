//
//  OptimizelyConfiguration.swift
//  Reversi_Example
//
//  Created by Benoit PASQUIER on 12/03/2019.
//  Copyright © 2019 Benoit PASQUIER. All rights reserved.
//

import Foundation
import Reversi
import OptimizelySDKiOS

class OptimizelyConfiguration : ReversiConfigurationProtocol {
    
    var isConfigured: Bool = false
    var userId: String = "XYZ"
    var optimizelyClient: OPTLYClient?
    
    func setup() {
        
        let optimizelyManager = OPTLYManager(builder: OPTLYManagerBuilder(block: { (builder) in
            builder?.sdkKey = "SDK_KEY_HERE"
        }))
        
        optimizelyManager?.initialize(callback: { [weak self] (error, optimizelyClient) in
            self?.optimizelyClient = optimizelyClient
        })
    }
    
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
}
