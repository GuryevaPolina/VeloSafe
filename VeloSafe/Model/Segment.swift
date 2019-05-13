//
//  Segment.swift
//  VeloSafe
//
//  Created by defaultUser on 13/05/2019.
//  Copyright © 2019 polinaguryeva. All rights reserved.
//

import Foundation

struct Segment: Hashable {
    
    var firstPointId: String
    var secondPointId: String
    
    var hashValue: Int {
        return (firstPointId + secondPointId).hashValue
    }
    
    static func == (lhs: Segment, rhs: Segment) -> Bool {
        return lhs.firstPointId == rhs.firstPointId && lhs.secondPointId == rhs.secondPointId
    }
    
}
