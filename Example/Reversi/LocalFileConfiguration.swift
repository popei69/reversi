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
    var experiments: [String : Any]
    
    init(from fileName: String) {
        
        let data = FileManager.readDictionaryJson(forResource: fileName)
        self.experiments = (data?["experiments"] as? [[String: Any]])
            .flatMap({ $0 })?
            .reduce([String: Any](), { (dictionary, experiment) in
                var nextDic = dictionary
                if let keyExperiment = experiment["key"] as? String,
                    let valueExperiment = experiment["value"] {
                    nextDic[keyExperiment] = valueExperiment
                }
                return nextDic
            }) ?? [:]
            
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
    
    static func readDictionaryJson(forResource fileName: String) -> [String: Any]? {
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "json"){
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                // handle error
            }
        }
        
        return nil
    }

}
