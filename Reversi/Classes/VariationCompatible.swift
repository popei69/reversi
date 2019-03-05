//
//  VariationCompatible.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

import class Foundation.NSObject

public protocol VariationCompatible {
    associatedtype VariationType
    func addVariation<T>(_ key: String, queue: DispatchQueue?, ofType: T.Type, variantOf: @escaping (VariationType, T) -> ()) -> VariationType
}

extension VariationCompatible where Self:NSObject {
    
    @discardableResult
    public func addVariation<Value>(_ key: String, queue: DispatchQueue? = nil, ofType: Value.Type, variantOf variant: @escaping (Self, Value) -> ()) -> Self {
        let variation = Variation<Value>(self, key: key, variantOf: variant)
        ReversiService.shared.executeVariation(variation)
        return self
    }
}

extension NSObject: VariationCompatible { }
