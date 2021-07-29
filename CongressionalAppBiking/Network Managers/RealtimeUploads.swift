//
//  RealtimeUploads.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/25/21.
//

import Foundation
import FirebaseDatabase
import CoreLocation

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
        
        guard let email = User.email else {
            completion(false, "User email not available")
            return
        }
        
        let locationManager = CLLocationManager()
        
        guard CLLocationManager.locationServicesEnabled() else {
            completion(false, "Location Service not Enabled")
            return
        }
        
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        
        let path = "rides/\(group)/locations/\(email)/location/"
        
        RealtimeUpload.upload(data: latitude! , path: path + "latitude")
        RealtimeUpload.upload(data: longitude! , path: path + "latitude")
        
        completion(true, nil)
    }
}
