//
//  ReversiConfiguration.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 04/03/2019.
//

public protocol ReversiConfigurationProtocol {
    func canExecute<T>(_ variation: Variation<T>) -> Bool
    func execute<T>(_ variation: Variation<T>, options: [String: Any]?)
}
