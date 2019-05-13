//
//  StreetGraph.swift
//  VeloSafe
//
//  Created by Polina on 28/03/2019.
//  Copyright © 2019 polinaguryeva. All rights reserved.
//

import Foundation
import SWXMLHash

enum TurnDirection {
    case left
    case right
    case none
}

class StreetGraph {
    
    var edgeList = [Edge]()
    var nodes = [String: OSMNode]()
    
    let bounds: OSMBounds
    
    init(osm: OSM) {
        self.bounds = osm.bounds
        self.nodes = osm.nodes
        createEdgeList(osm: osm)
    }
    
    func createEdgeList(osm: OSM) {
        for way in osm.ways {
            for i in 0..<way.nodes.count - 1 {
                let edge = Edge(from: way.nodes[i],
                                to: way.nodes[i + 1])
                self.edgeList.append(edge)
            }
        }
    }
    
    public func nodes(near startLocation: GeoPoint, radius searchRadius: Int = 50) -> [OSMNode] {
        var found = Array<OSMNode>()
        
        for (_, node) in nodes {
            let distance = startLocation.distance(to: node.location)
            if distance < Double(searchRadius) {
                found.append(node)
            }
        }
        
        return found.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.location.distance(to: startLocation) < rhs.location.distance(to: startLocation)
        })
    }
    
}
