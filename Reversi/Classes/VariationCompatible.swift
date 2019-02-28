//
//  VariationCompatible.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

import class Foundation.NSObject

public protocol VariationCompatible {
    associatedtype VariationType
    func addVariation(_ key: String, queue: DispatchQueue?, variantOf: @escaping (VariationType) -> ()) -> VariationType 
}

extension VariationCompatible where Self:NSObject {
    
    @discardableResult
    public func addVariation(_ key: String, queue: DispatchQueue? = nil, variantOf variant: @escaping (Self) -> ()) -> Self {
        let variation = Variation(self, key: key, variantOf: variant)
        ReversiService.shared.executeVariation(variation)
        return self
    }
}

extension NSObject: VariationCompatible { }
