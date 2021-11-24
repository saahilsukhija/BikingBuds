//
//  Ride.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 11/19/21.
//

import Foundation

struct Ride: Codable {
    var id: String!
    var name: String!

}

extension Array where Element == Ride {
    func rideFor(id: String) -> Ride? {
        for ride in self {
            if ride.id == id {
                return ride
            }
        }
        
        return nil
    }
    
    func rideFor(name: String) -> Ride? {
        for ride in self {
            if ride.name == name {
                return ride
            }
        }
        
        return nil
    }
    
    func containsRide(_ ride: Ride) -> Bool {
        if self.rideFor(id: ride.id) == nil {
            return false
        }
        return true
    }
}
