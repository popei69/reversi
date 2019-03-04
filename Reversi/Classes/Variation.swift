//
//  Variation.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

public struct Variation<Value> {
    public let key: String 
    private let _variationBlock : (Value) -> ()
    
    public init<Type: NSObject>(_ object: Type, key: String, variantOf: @escaping (Type, Value) -> ()) {
        
        weak var weakObject = object
        
        self.key = key
        self._variationBlock = { value in
            DispatchQueue.main.async {
                guard let object = weakObject else { return }
                variantOf(object, value)
            }
        }
    }
    
    public func execute(with value: Value) {
        self._variationBlock(value)
    } 
}
