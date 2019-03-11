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
    private var configuration: ReversiConfigurationProtocol!
    
    private var isConfigured = false
    
    public func configure(with configuration: ReversiConfigurationProtocol) throws {
        guard !isConfigured else {
            throw ReversiError.alreadyConfigured
        }
        self.configuration = configuration
        isConfigured = true
    }
    
    public func executeVariation<T>(_ variation: Variation<T>, options: [String: Any]? = nil) {
        if configuration == nil {
            fatalError("Make sure ReversiConfigurationProtocol is properly setup")
        }
        
        if configuration.canExecute(variation) {
            configuration.execute(variation, options: options)
        }
    }
}
