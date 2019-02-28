//
//  ReversiService.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

public final class ReversiService {
    
    public static let shared = ReversiService()
    
    public private(set) var expirements: [String] = []
    
    public func configure(with expirements: [String]) {
        self.expirements = expirements
    }
    
    private func canExecuteVariation(_ variation: Variation) -> Bool {
        return expirements.contains(variation.key)
    }
    
    public func executeVariation(_ variation: Variation) {
        if canExecuteVariation(variation) {
            variation.execute()
        }
    }
}
