//
//  Path.swift
//  VeloSafe
//
//  Created by Polina on 20/05/2019.
//  Copyright © 2019 polinaguryeva. All rights reserved.
//

import Foundation

class AStarPathfinder {
    
    private var graph: StreetGraph
    
    init(_ graph: StreetGraph) {
        self.graph = graph
    }
    
    func searchPath(from: OSMNode, to: OSMNode) -> [OSMNode] {
        var path = [OSMNode]()
        
        let stepFrom = AStarPathStep(node: from)
        let stepTo = AStarPathStep(node: to)
        
        var openList = [AStarPathStep]()
        var closeList = [AStarPathStep]()
        
        openList.append(stepFrom)
        
        while !openList.isEmpty {
            var currentIndex = 0
            var currentNode = openList[currentIndex]
            
            for (i, node) in openList.enumerated() {
                if node.f < currentNode.f {
                    currentNode = node
                    currentIndex = i
                }
            }
            
            openList.remove(at: currentIndex)
            closeList.append(currentNode)
            
            if currentNode == stepTo {
                path = []
                var current: AStarPathStep? = currentNode
                while current != nil {
                    path.append(current!.node)
                    current = current?.parent
                }
                return path.reversed()
            }
            
            var children = [AStarPathStep]()
            for node in currentNode.node.adjacent {
                let newChild = AStarPathStep(node: node)
                newChild.setParent(currentNode, with: 1)
                children.append(newChild)
            }
            
            childLoop: for child in children {
                for closed in closeList {
                    if child == closed {
                        continue childLoop
                    }
                }
                if let parent = currentNode.parent?.node {
                    switch graph.turnDirectionTable[Segment(from: parent, to: child.node)] ?? .left {
                    case .left:
                        child.g = currentNode.g + 1
                    case .right, .none:
                        child.g = currentNode.g + 1000
                    }
                }
                
                //child.g = currentNode.g + 1
                child.h = hScore(from: child, to: stepTo)
                
                for open in openList {
                    if child == open && child.g > open.g {
                        continue childLoop
                    }
                }
                openList.append(child)
            }
            
        }
        
        return path
    }
    
    private func hScore(from: AStarPathStep, to: AStarPathStep) -> Double {
        return from.node.location.distance(to: to.node.location)
    }
}
