//
//  VariationCompatible.swift
//  Pods
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

public protocol VariationCompatible {
    associatedtype CompatibleType
    func addVariation<CompatibleType>(_ key: String, queue: DispatchQueue?, variantOf: @escaping (CompatibleType) -> ()) -> CompatibleType 
}

final class VariationService {
    static let shared = VariationService() 
    
    var expirements: [String] = []
    
    private func canExecuteVariation<T>(_ variation: Variation<T>) -> Bool {
        return expirements.contains(variation.key)
    }
    
    public func executeVariation<T>(_ variation: Variation<T>) {
        if canExecuteVariation(variation) {
            variation.execute()
        }
    }
}

extension VariationCompatible where Self : AnyObject {
    
    public func addVariation(_ key: String, queue: DispatchQueue? = nil, variantOf variant: @escaping (Self) -> ()) -> Self {
        let variation = Variation<Self>(self, key: key, variantOf: variant)
        VariationService.shared.executeVariation(variation)
        return self
    }
}
