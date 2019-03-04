//
//  VariationCompatible.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

import class Foundation.NSObject

public protocol VariationCompatible {
    associatedtype VariationType
    func addVariation<T>(_ key: String, queue: DispatchQueue?, variantOf: @escaping (VariationType, T) -> ()) -> VariationType 
}

extension VariationCompatible where Self:NSObject {
    
    @discardableResult
    public func addVariation<T>(_ key: String, queue: DispatchQueue? = nil, variantOf variant: @escaping (Self, T) -> ()) -> Self {
        let variation = Variation<T>(self, key: key, variantOf: variant)
        ReversiService.shared.executeVariation(variation)
        return self
    }
    
    @discardableResult
    public func addVariation(_ key: String, queue: DispatchQueue? = nil, variantOf variant: @escaping (Self, Bool) -> ()) -> Self {
        let variation = Variation<Bool>(self, key: key, variantOf: variant)
        ReversiService.shared.executeVariation(variation)
        return self
    }
}

extension NSObject: VariationCompatible { }
