//
//  LocationUpdates.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/2/21.
//

import UIKit
import FirebaseDatabase
import CoreLocation

struct Locations {
    static var locations: [String : CLLocationCoordinate2D]!
    
    static func addNotifications(for group: String) {
        print("adding notifications...")
        let ref = Database.database().reference().child("rides/" + group)
        
        ref.observe(.value) { snapshot in
            
            guard snapshot.exists() else {
                print("no snap exists")
                return
            }
            
            self.locations = [:]
            for user in snapshot.children.allObjects as! [DataSnapshot] {
    
                let locationSnap = user.childSnapshot(forPath: "location")
                let userEmail = user.key.fromStorageEmail()
                
                if locationSnap.exists() {
                    
                    let locationDictionary = locationSnap.value as! [String : Any]
                    let coordinate = CLLocationCoordinate2D(
                        latitude: locationDictionary["latitude"] as! CLLocationDegrees,
                        longitude: locationDictionary["longitude"] as! CLLocationDegrees)
                    
                    self.locations[userEmail] = coordinate
                }
            }
            
            NotificationCenter.default.post(name: .locationUpdated, object: nil)
        }
 
    }
}
