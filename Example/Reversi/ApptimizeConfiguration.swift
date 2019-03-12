//
//  ApptimizeConfiguration.swift
//  Reversi_Example
//
//  Created by Benoit PASQUIER on 11/03/2019.
//  Copyright © 2019 Benoit PASQUIER. All rights reserved.
//

import Foundation
import Reversi
//import Apptimize

final class ApptimizeConfiguration : ReversiConfigurationProtocol {
    
    func setup() {
        Apptimize.start(withApplicationKey: "XYZ")
    }
    
    // MARK: - ReversiConfigurationProtocol
    
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
            
            if let variation = variation as? Variation<Bool> {
                variation.execute(with: true)
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
}
