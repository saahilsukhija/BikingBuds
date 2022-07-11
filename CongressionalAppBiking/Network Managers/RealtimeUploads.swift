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
    
    static func remove(path: String) {
        let ref = Database.database().reference().child(path)
        ref.removeValue { error, ref in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

struct AnnouncementUpload {
    static func uploadAnnouncement(_ announcement: String, group: String, completion: @escaping((Bool, String?) -> Void)) {
        
        guard let user = Auth.auth().currentUser else {
            completion(false, "User not available")
            return
        }
        
        let path = "rides/\(group)/announcements"
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = df.string(from: Date())
        
        let ref = Database.database().reference().child(path)
        let dict = ["announcement" : announcement, "uploaded" : now, "user" : user.email!.toLegalStorageEmail()]
        ref.childByAutoId().setValue(dict)
        completion(true, nil)
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
        let token = Authentication.deviceToken
        RealtimeUpload.upload(data: ["rider_type" : legalRiderType, "location" : locationDict, "device_token" : token as Any], path: path)
        completion(true, nil)
    }
    
    static func uploadUserRideType(_ rideType: RiderType, group: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let path = "rides/\(group)/\(user.email!.toLegalStorageEmail())/rider_type/"
        RealtimeUpload.upload(data: HelperFunctions.makeLegalRiderType(rideType), path: path)
    }
    
    
    static func uploadUserDeviceToken(_ token: String? = Authentication.deviceToken, group: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        guard let token = token else {
            print("error uploading token")
            return
            
        }
        
        print("uploading token...")
        let path = "rides/\(group)/\(user.email!.toLegalStorageEmail())/device_token/"
        RealtimeUpload.upload(data: token, path: path)
    }
    
    static func riderLeftGroup(group: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let ref = Database.database().reference().child("rides/\(group)")
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.childrenCount == 2 {
                //Single person, remove whole group
                RealtimeUpload.remove(path: "rides/\(group)")
            } else {
                //Multi Person, only remove one person
                let path = "rides/\(group)/\(user.email!.toLegalStorageEmail())/"
                RealtimeUpload.remove(path: path)
            }
        }
        
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
