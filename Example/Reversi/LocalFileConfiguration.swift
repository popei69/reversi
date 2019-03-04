//
//  RemoteConfiguration.swift
//  Reversi_Example
//
//  Created by Benoit PASQUIER on 04/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Reversi

class LocalFileConfiguration : ReversiConfigurationProtocol {
    var experiments: [String : String]
    
    init(from fileName: String) {
        self.experiments = FileManager.readDictionaryJson(forResource: fileName) ?? [:]
    }
}

extension FileManager {
    
    static func readArrayJson<T: Codable>(forResource fileName: String ) -> [T]? {
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "json"){
            do {
                let jsonDecoder = JSONDecoder()
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonArray = try jsonDecoder.decode([T].self, from: data)
                return jsonArray
            } catch {
                // handle error
            }
        }
        
        return nil
    }
    
    static func readDictionaryJson(forResource fileName: String) -> [String: String]? {
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "json"){
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                // handle error
            }
        }
        
        return nil
    }

}
