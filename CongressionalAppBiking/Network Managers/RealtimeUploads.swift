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
    static func uploadCurrentLocation(group: String, location: CLLocationCoordinate2D, completion: @escaping((Bool, String?) -> Void)) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "User not available")
            return
        }
        
        let (latitude, longitude) = (location.latitude.roundTo(places: Preferences.coordinateRoundTo), location.longitude.roundTo(places: Preferences.coordinateRoundTo))
        
        guard latitude != 0 || longitude != 0 else {
            completion(false, "Location Service not Enabled")
            return
        }
        
        let path = "rides/\(group)/\(user.email!.toLegalStorageEmail())/"

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = df.string(from: Date())
        
        let locationDict = ["latitude" : latitude, "longitude" : longitude, "last_updated" : now] as [String : Any]
        let legalRiderType = HelperFunctions.makeLegalRiderType(Authentication.riderType ?? .rider)
        RealtimeUpload.upload(data: ["rider_type" : legalRiderType, "location" : locationDict], path: path)
        completion(true, nil)
    }
    
    static func uploadUserRideType(_ rideType: RiderType, group: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let path = "rides/\(group)/\(user.email!.toLegalStorageEmail())/rider_type/"
        RealtimeUpload.upload(data: HelperFunctions.makeLegalRiderType(rideType), path: path)
    }
}

///Returns users current location
struct UserLocation {
    static func getUserCurrentLocation() -> (Double, Double) {
        let locationManager = CLLocationManager()
        
        guard CLLocationManager.locationServicesEnabled() else {
            print("oops1")
            return (0, 0)
        }
        
        let coordinate = locationManager.location!.coordinate.roundTo(places: Preferences.coordinateRoundTo)
        return(coordinate.latitude, coordinate.longitude)
    }
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
