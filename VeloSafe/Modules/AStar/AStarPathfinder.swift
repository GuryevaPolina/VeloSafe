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
    private var from: AStarPathStep!
    private var to: AStarPathStep!
    
    init(_ graph: StreetGraph) {
        self.graph = graph
    }
    
    func searchPath(from firstNode: OSMNode, to secondNode: OSMNode) -> ([OSMNode], Int) {
        var path = [OSMNode]()
        
        from = AStarPathStep(node: firstNode)
        to = AStarPathStep(node: secondNode)
        
        var openList = [AStarPathStep]()
        var closeList = [AStarPathStep]()
        
        var n = 0
        
        openList.append(from)
        
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
            
            if currentNode == to {
                path = []
                var current: AStarPathStep? = currentNode
                while current != nil {
                    path.append(current!.node)
                    current = current?.parent
                }
                return (path.reversed(), n)
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
                        n += 1
                        child.g = currentNode.g + 1
                    case .right, .none:
                        child.g = currentNode.g + 1
                    }
                }
                
                child.h = hScore(child, to)
                
                for open in openList {
                    if child == open && child.g > open.g {
                        continue childLoop
                    }
                }
                openList.append(child)
            }
            
        }
        
        return (path, 0)
    }
    
    private func hScore(_ firstNode: AStarPathStep, _ secondNode: AStarPathStep) -> Double {
        
        let d = (secondNode.node.location.latitude - from.node.location.latitude) * (firstNode.node.location.longitude - from.node.location.longitude) - (secondNode.node.location.longitude - from.node.location.longitude) * (firstNode.node.location.latitude - from.node.location.latitude)
        
        if d >= 0 {
            return from.node.distance(to: to.node)
        } else {
            return from.node.distance(to: to.node)
        }
        
        
    }
}
