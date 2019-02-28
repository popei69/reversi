//
//  Variation.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

public struct Variation {
    
    public let key: String 
    private let _variationBlock : () -> ()
    
    public init<Type: NSObject>(_ object: Type, key: String, variantOf: @escaping (Type) -> ()) {
        
        weak var weakObject = object
        
        self.key = key
        self._variationBlock = { 
            DispatchQueue.main.async {
                guard let object = weakObject else { return }
                variantOf(object)
            }
        }
    }
    
    public func execute() {
        self._variationBlock()
    } 
}
