//
//  OSMBounds.swift
//  VeloSafe
//
//  Created by Polina on 28/03/2019.
//  Copyright © 2019 polinaguryeva. All rights reserved.
//

import Foundation
import SWXMLHash

public struct OSMBounds {
    
    let minLat: Double
    let minLon: Double
    let maxLat: Double
    let maxLon: Double
    
    init() {
        self.minLat = 0.0
        self.minLon = 0.0
        self.maxLat = 0.0
        self.maxLon = 0.0
    }
    
    init(xml: XMLIndexer) throws {
        self.minLat = try xml.value(ofAttribute: "minlat")
        self.minLon = try xml.value(ofAttribute: "minlon")
        self.maxLat = try xml.value(ofAttribute: "maxlat")
        self.maxLon = try xml.value(ofAttribute: "maxlon")
    }
    
    func contains(point: GeoPoint) -> Bool {
        if minLat ... maxLat ~= point.latitude && minLon ... maxLon ~= maxLon {
            return true
        }
        return false
    }
}

