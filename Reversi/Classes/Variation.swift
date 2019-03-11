//
//  Variation.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

public enum VariationType {
    case featureFlag
    case variant
} 

public struct Variation<Value> {
    public let key: String 
    public let type: VariationType
    private let variationBlock : (Value) -> ()
    
    public init<Type: NSObject>(_ object: Type, key: String, type: VariationType, variantOf: @escaping (Type, Value) -> ()) {
        
        weak var weakObject = object
        
        self.key = key
        self.type = type
        self.variationBlock = { value in
            DispatchQueue.main.async {
                guard let object = weakObject else { return }
                variantOf(object, value)
            }
        }
    }
    
    public init<Type: NSObject>(_ object: Type, key: String, type: VariationType, variantOf: @escaping (Type) -> ()) {
        
        weak var weakObject = object
        
        self.key = key
        self.type = type
        self.variationBlock = { _ in
            DispatchQueue.main.async {
                guard let object = weakObject else { return }
                variantOf(object)
            }
        }
    }
    
    public func execute(with value: Value) {
        self.variationBlock(value)
    } 
}
