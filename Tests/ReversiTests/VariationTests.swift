//
//  VariationTests.swift
//  Reversi_Tests
//
//  Created by Benoit PASQUIER on 23/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import Reversi

class VariationTests: XCTestCase {
    
    static var allTests = [
        ("testCreateVariant", testCreateVariant),
        ("testVariantExecuteWithValue", testVariantExecuteWithValue),
        ("testCreateFeatureVariation", testCreateFeatureVariation),
        ("testFeatureFlagExecute", testFeatureFlagExecute)
    ]

    func testCreateVariant() {
        
        // given specific parameters
        let key = "key"
        let variant : ((XCTestCase, String) -> Void) = { _, _ in }
        
        // when creating a variation
        let variation = Variation<String>.init(self, key: key, type: .variant, variantOf: variant)
        
        // expecting same parameters
        XCTAssertEqual(variation.key, key)
        XCTAssertEqual(variation.type, .variant)
        XCTAssertNotEqual(variation.type, .featureFlag)
    }
    
    func testVariantExecuteWithValue() {
        
        let expectation = XCTestExpectation(description: "Variant execution")
        let expectedValue = "expectedValue"
        
        // given a variation
        let variation = Variation<String>.init(self, key: "key", type: .variant) { (test, value) in
            XCTAssertEqual(expectedValue, value)
            expectation.fulfill()
        }
        
        // when executing the variation with value
        // expected to capture that value
        variation.execute(with: expectedValue)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testCreateFeatureVariation() {
        
        // given specific parameters
        let key = "key"
        
        // when creating a feature flag variation
        let variation = Variation<Void>.init(self, key: key, type: .featureFlag) { _ in
            print("feature flag variation")
        }
        
        // expecting same parameters
        XCTAssertEqual(variation.key, key)
        XCTAssertEqual(variation.type, .featureFlag)
        XCTAssertNotEqual(variation.type, .variant)
    }
    
    func testFeatureFlagExecute() {
        
        let expectation = XCTestExpectation(description: "Variant execution")
        
        // given a variation
        let variation = Variation<Void>.init(self, key: "key", type: .featureFlag) { test in
            print("feature flag variation")
            XCTAssertNotNil(test)
            expectation.fulfill()
        }
        
        // when executing the variation
        // expected to execute that variation
        variation.execute(with: ())
        
        wait(for: [expectation], timeout: 2.0)
    }
}
