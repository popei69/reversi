//
//  ReversiService.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 28/02/2019.
//

public final class ReversiService {
    
    public static let shared = ReversiService()
    
    public private(set) var experiments: [String : String] = [:]
    
    public func configure(with configuration: ReversiConfigurationProtocol) {
        self.configure(with: configuration.experiments)
    }
    
    private func configure(with expirements: [String : String]) {
        self.experiments = expirements
    }
    
    public func executeVariation<T>(_ variation: Variation<T>) {
        
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
