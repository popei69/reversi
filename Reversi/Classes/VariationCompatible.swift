//
//  VariationCompatible.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//  Copyright © 2019 Benoit PASQUIER. All rights reserved.
//

import class Foundation.NSObject

public protocol VariationCompatible {
    associatedtype VariationType
    func addVariation<T>(_ key: String, queue: DispatchQueue?, for: T.Type, options: [String: Any]?, variantOf: @escaping (VariationType, T) -> ()) -> VariationType
    func addFeatureFlag(_ key: String, queue: DispatchQueue?, variantOf: @escaping (VariationType) -> ()) -> VariationType
}

extension VariationCompatible where Self:NSObject {
    
    @discardableResult
    public func addVariation<Value>(_ key: String, 
                                    queue: DispatchQueue? = nil, 
                                    for: Value.Type, 
                                    options: [String: Any]? = nil, 
                                    variantOf variant: @escaping (Self, Value) -> ()) -> Self {
        let variation = Variation<Value>(self, key: key, type: .variant, variantOf: variant)
        ReversiService.shared.executeVariation(variation, options: options)
        return self
    }
    
    @discardableResult
    public func addFeatureFlag(_ key: String, 
                               queue: DispatchQueue? = nil, 
                               variantOf variant: @escaping (Self) -> ()) -> Self {
        let variation = Variation<Void>(self, key: key, type: .featureFlag, variantOf: variant)
        ReversiService.shared.executeVariation(variation)
        return self
    }
}

extension NSObject: VariationCompatible { }
