//
//  ReversiService.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

import Foundation

final class ReversiService {
    static let shared = ReversiService() 
    
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
