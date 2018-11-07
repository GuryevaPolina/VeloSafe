//
//  GraphParser.swift
//  VeloSafe
//
//  Created by Polina Guryeva on 07/11/2018.
//  Copyright © 2018 polinaguryeva. All rights reserved.
//

import Foundation

class GraphParser {
    
    class func parseGraphFromFile(withPath path: String) -> ([Int: GeoPoint], ErrorType?) {
        var data: String = ""
        if FileManager.default.fileExists(atPath: path) && FileManager.default.isReadableFile(atPath: path) {
            do {
                data = try String(contentsOfFile: path, encoding: .utf8)
            } catch {
                print("[parseGraphFromFile] data is nil")
                return ([:], .parseError)
            }
        }
        var map = [Int: GeoPoint]()
        let lineArray = data.split(separator: "\n")
        
        for line in lineArray {
            let components = line.components(separatedBy: ":")
            guard let key = Int(components[0]), let latitude = Double(components[1]), let longitude = Double(components[2]) else {return ([:], .parseError)}
            map[key] = GeoPoint(latitude: latitude, longitude: longitude, description: components[3])
        }
        //print(map)
        return (map, nil)
    }
    
}
