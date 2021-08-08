//
//  RealtimeUploads.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/25/21.
//

import Foundation
import FirebaseDatabase
import CoreLocation
import FirebaseAuth
/// Makes it simpler to upload things to realtime database
struct RealtimeUpload {
    
    /// Upload "Any" Data to realtime database
    /// - Parameters:
    ///   - data: Any string, int, double, dictionary, or array
    ///   - path: Path from base ref to the desired area
    static func upload(data: Any, path: String) {
        let ref = Database.database().reference().child(path)
        ref.setValue(data)
    }
}

/// Upload users current location to realtime database quickly
struct UserLocationsUpload {
    static func uploadCurrentLocation(group: String, completion: @escaping((Bool, String?) -> Void)) {
        
        guard let email = Auth.auth().currentUser?.email else {
            completion(false, "User email not available")
            return
        }
        
        let (latitude, longitude) = UserLocation.getUserCurrentLocation()
        
        guard latitude != 0 || longitude != 0 else {
            completion(false, "Location Service not Enabled")
            return
        }
        
        let path = "rides/\(group)/\(email.toLegalStorageEmail())/location/"
        
        RealtimeUpload.upload(data: ["latitude" : latitude, "longitude" : longitude], path: path)
        print("uploaded user location")
        
        completion(true, nil)
    }
}

///Returns users current location
struct UserLocation {
    static func getUserCurrentLocation() -> (Double, Double) {
        let locationManager = CLLocationManager()
        
        guard CLLocationManager.locationServicesEnabled() else {
            return (0, 0)
        }
        
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        
        if let latitude = latitude, let longitude = longitude {
            return(latitude.roundTo(places: 4), longitude.roundTo(places: 4))
        } else {
            return (0, 0)
        }
    }
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
