//
//  ReversiService.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

public enum ReversiError : Error {
    case alreadyConfigured
}

public final class ReversiService {
    
    public static let shared = ReversiService()
    
    private var experiments: [String : Any] = [:]
    private var isConfigured = false
    
    public func configure(with configuration: ReversiConfigurationProtocol) throws {
        try self.configure(with: configuration.experiments)
    }
    
    private func configure(with expirements: [String : Any]) throws {
        guard !isConfigured else {
            throw ReversiError.alreadyConfigured
        }
        
        self.experiments = expirements
        isConfigured = true
    }
    
    public func executeVariation<T>(_ variation: Variation<T>) {
        
        // detect Void type
        if let variation = variation as? Variation<Void>, 
            experiments.contains(where: { $0.key == variation.key }) {
            variation.execute(with: ())
            return
        }
        
        if let value = experiments[variation.key] as? T {
            variation.execute(with: value)
        }
    }
}
