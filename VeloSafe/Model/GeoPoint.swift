//
//  GeoPoint.swift
//  VeloSafe
//
//  Created by Polina Guryeva on 07/11/2018.
//  Copyright © 2018 polinaguryeva. All rights reserved.
//

import Foundation

class GeoPoint {
    var latitude: Double
    var longitude: Double
    var description: String
    
    init(latitude: Double, longitude: Double, description: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
    }
}
