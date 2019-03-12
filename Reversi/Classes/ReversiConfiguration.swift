//
//  ReversiConfiguration.swift
//  Reversi
//
//  Created by Benoit PASQUIER on 04/03/2019.
//  Copyright © 2019 Benoit PASQUIER. All rights reserved.
//

public protocol ReversiConfigurationProtocol {
    func canExecute<T>(_ variation: Variation<T>) -> Bool
    func execute<T>(_ variation: Variation<T>, options: [String: Any]?)
}
