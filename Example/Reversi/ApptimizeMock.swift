//
//  ApptimizeMock.swift
//  Reversi_Example
//
//  Created by Benoit PASQUIER on 11/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

class Apptimize { 
    static func start(withApplicationKey: String) { }
    static func runTest(_ testName: String, withBaseline:(() -> ()), andApptimizeCodeBlocks: [ApptimizeCodeBlock]) { }
    static func isFeatureFlag(on key: String) -> Bool { return true } 
    
}

struct ApptimizeCodeBlock {
    let name: String 
    let block: (() -> ())
}
