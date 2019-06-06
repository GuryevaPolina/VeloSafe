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
    var streetNames = [String]()
    
    public init(xml: XMLIndexer) throws {
        let xmlNodes = xml["osm"]["node"]
        for xmlNode in xmlNodes.all {
            let node = try OSMNode(xml: xmlNode, osm: self)
            self.nodes[node.id] = node
        }
        
        var streets = Set<String>()
        for xmlWay in xml["osm"]["way"].all {
            let way = try OSMWay(xml: xmlWay, osm: self)
            
            let allowedHighwayValues = ["living_street", "cycleway", "motorway", "trunk", "primary", "secondary", "tertiary", "motorway_link", "trunk_link", "primary_link", "secondary_link", "tertiary_link", "unclassified", "road", "residential"]
            let oneWayMarkers = ["yes"]
            
            if let highwayValue = way.tags["highway"], allowedHighwayValues.contains(highwayValue) {
                for node in way.nodes {
                    self.nodes[node.id]?.ways.insert(way)
                }
                if let oneWay = way.tags["oneway"], oneWayMarkers.contains(oneWay) {
                    way.isOneWay = true
                }
                self.ways.insert(way)
            }
            
            
            if let streetName = way.tags["name"] {
                streets.insert(streetName)
//                if streetName.contains("Политехническая") {
//                    print(way.nodes.first?.id ?? "error")
//                }
//                if streetName.contains("Новолитовская") {
//                    print(way.nodes.randomElement()?.id ?? "error")
//                }
            }
        }
        
        self.nodes = self.nodes.filter({ !$0.value.ways.isEmpty })
        
//        DispatchQueue.main.async {
//            print(self.nodes.count)
//        }
//
//        DispatchQueue.main.async {
//            print(self.ways.count)
//        }
        
        let xmlBounds = xml["osm"]["bounds"]
        self.bounds = try OSMBounds(xml: xmlBounds)
        
        self.streetNames = Array(streets).sorted()
        
        DispatchQueue.main.async {
            print("osm init complete")
            //print("streets: \(self.streetNames)")
        }
    }
    
}

