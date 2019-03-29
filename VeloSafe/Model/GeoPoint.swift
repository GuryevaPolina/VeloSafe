//
//  GeoPoint.swift
//  VeloSafe
//
//  Created by Polina Guryeva on 07/11/2018.
//  Copyright © 2018 polinaguryeva. All rights reserved.
//

import Foundation

struct GeoPoint {
    var latitude: Double
    var longitude: Double
    
    private func radians(degrees: Double) -> Double {
        return degrees * Double.pi / 180.0
    }
    
    func distance(to: GeoPoint) -> Double {
        
        let deltaLatitude = radians(degrees: to.latitude - latitude)
        let deltaLongitude = radians(degrees: to.longitude - longitude)
        
        let a: Double = pow(sin(deltaLatitude / 2), 2) + cos(radians(degrees: latitude)) * cos(radians(degrees: to.latitude)) * pow(sin(deltaLongitude / 2), 2)
        let c: Double = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return C.earthRadius * c
    }
    
    private struct C {
         static let earthRadius = 6371000.0
    }
}
