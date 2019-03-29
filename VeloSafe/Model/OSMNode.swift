//
//  OSMNode.swift
//  VeloSafe
//
//  Created by Polina on 28/03/2019.
//  Copyright © 2019 polinaguryeva. All rights reserved.
//

import Foundation
import SWXMLHash

class OSMNode: Taggable {
    
    private weak var osm: OSM?
    
    let id: String
    let location: GeoPoint
    let tags: [String: String]
    
    var ways = Set<OSMWay>()
    
    var adjacent = Set<OSMNode>()
    
    init(xml: XMLIndexer, osm: OSM) throws {
        self.id = try xml.value(ofAttribute: "id")
        
        let lat: Double = try xml.value(ofAttribute: "lat")
        let lon: Double = try xml.value(ofAttribute: "lon")
        self.location = GeoPoint(latitude: lat, longitude: lon)
        
        var tags = [String: String]()
        for xmlTag in xml["tag"].all {
            tags[try xmlTag.value(ofAttribute: "k")] = xmlTag.value(ofAttribute: "v")
        }
        self.tags = tags
        
        self.osm = osm
    }
    
    func distance(to: OSMNode) -> Double {
        return location.distance(to: to.location)
    }
    
}

extension OSMNode: Hashable {
    var hashValue: Int {
        return self.id.hashValue
    }
}

extension OSMNode: Equatable {
    static func ==(lhs: OSMNode, rhs: OSMNode) -> Bool {
        return lhs.id == rhs.id
    }
}

extension OSMNode: Comparable {
    static func <(lhs: OSMNode, rhs: OSMNode) -> Bool {
        return lhs.id < rhs.id
    }
}
