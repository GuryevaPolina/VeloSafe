//
//  OSM.swift
//  VeloSafe
//
//  Created by Polina on 28/03/2019.
//  Copyright © 2019 polinaguryeva. All rights reserved.
//

import Foundation
import SWXMLHash

protocol Taggable {
    var tags: [String: String] { get }
}

public class OSM {
    
    var nodes = [String: OSMNode]()
    var ways = Set<OSMWay>()
    var bounds = OSMBounds()
    
    public init(xml: XMLIndexer) throws {
        let xmlNodes = xml["osm"]["node"]
        for xmlNode in xmlNodes.all {
            let node = try OSMNode(xml: xmlNode, osm: self)
            self.nodes[node.id] = node
        }
        
        for xmlWay in xml["osm"]["way"].all {
            let way = try OSMWay(xml: xmlWay, osm: self)
            
            let allowedHighwayValues = ["motorway", "motorway_link", "trunk", "trunk_link", "primary", "primary_link", "secondary", "secondary_link", "tertiary", "tertiary_link", "unclassified", "road", "residential", "living_street", "cycleway"]
            if let highwayValue = way.tags["highway"], allowedHighwayValues.contains(highwayValue) {
                for node in way.nodes {
                    self.nodes[node.id]?.ways.insert(way)
                }
                self.ways.insert(way)
            }
        }
        
        self.nodes = self.nodes.filter({ !$0.value.ways.isEmpty && !$0.value.adjacent.isEmpty })
        
        DispatchQueue.main.async {
            print(self.nodes.count)
        }
        
        DispatchQueue.main.async {
            print(self.ways.count)
        }
        
        let xmlBounds = xml["osm"]["bounds"]
        self.bounds = try OSMBounds(xml: xmlBounds)
        
        DispatchQueue.main.async {
            print("osm init complete")
        }
    }
    
}

