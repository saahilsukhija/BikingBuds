//
//  CLLocationCoordinate.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 6/15/24.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    static public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return (fabs(lhs.latitude - rhs.latitude) <= .ulpOfOne) && (fabs(lhs.longitude - rhs.longitude) <= .ulpOfOne)
    }
}
