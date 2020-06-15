//
//  ReversiServiceTests.swift
//  Reversi_Tests
//
//  Created by Benoit PASQUIER on 23/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import Reversi

final class ReversiServiceTests: XCTestCase {
    
    fileprivate var configuration: MockConfiguration!
    
    
    static var allTests = [
        ("testVariationWithNoConfig", testVariationWithNoConfig),
        ("testValidExperiment", testValidExperiment),
        ("testValidFeatureFlag", testValidFeatureFlag),
    ]

    override func setUp() {
        super.setUp()
        configuration = MockConfiguration()
        try? ReversiService.shared.configure(with: configuration)
    }

    override func tearDown() {
        configuration = nil
        super.tearDown()
    }
    
    func testVariationWithNoConfig() {
        
    }

    func testValidExperiment() {
        
        // giving a valid experiment
        let expectation = XCTestExpectation(description: "Variant execution")
        let key = "key"
        let expectedValue = true
        configuration.experiments[key] = expectedValue
        
        let object = NSObject()
        object.addVariation(key, for: Bool.self) { _, value in
            XCTAssertEqual(expectedValue, value)
            expectation.fulfill()
        }   
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testValidFeatureFlag() {
        
        let expectation = XCTestExpectation(description: "Variant execution")
        let key = "key"
        let expectedValue = true
        configuration.experiments[key] = expectedValue
        
        let object = NSObject()
        object.addFeatureFlag(key) { _ in
            expectation.fulfill()
        }   
        
        wait(for: [expectation], timeout: 2.0)
    }

}

fileprivate class MockConfiguration: ReversiConfigurationProtocol {
    
    var experiments: [String : Any] = [:]
    
    func canExecute<T>(_ variation: Variation<T>) -> Bool {
        return experiments[variation.key] != nil
    }
    
    func execute<T>(_ variation: Variation<T>, options: [String : Any]?) {
        
        // detect Void type
        if let variation = variation as? Variation<Void>, 
            experiments.contains(where: { $0.key == variation.key }) {
            variation.execute(with: ())
            return
        }
        
        if let value = experiments[variation.key] as? T {
            variation.execute(with: value)
            return
        }
    }
} 
