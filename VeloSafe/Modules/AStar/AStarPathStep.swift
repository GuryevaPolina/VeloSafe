//
//  AStarPathStep.swift
//  VeloSafe
//
//  Created by Polina on 21/05/2019.
//  Copyright © 2019 polinaguryeva. All rights reserved.
//

import Foundation

class AStarPathStep {
    
    var node: OSMNode
    var parent: AStarPathStep?
    
    var g = 0.0
    var h = 0.0
    var f: Double {
        return g + h
    }
    
    init(node: OSMNode) {
        self.node = node
    }
    
    func setParent(_ parent: AStarPathStep, with cost: Double) {
        self.parent = parent
        self.g = parent.g + cost
    }
    
    static func == (lhs: AStarPathStep, rhs: AStarPathStep) -> Bool {
        return lhs.node == rhs.node
    }
}
