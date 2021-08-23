//
//  LocationUpdates.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/2/21.
//

import UIKit
import FirebaseDatabase
import CoreLocation
import FirebaseAuth

struct Locations {
    static var locations: [GroupUser : CLLocationCoordinate2D]! = [:]
    static var groupUsers: [GroupUser]! = []
    
    ///Add notifications for user locations updating in a group
    static func addNotifications(for group: String) {
        
        
        let ref = Database.database().reference().child("rides/" + group)
        
        ref.observe(.childChanged) { snapshot in
            print("child changed")
            
            let changedEmail = snapshot.key.fromStorageEmail()
            if let changedGroupUser = (Array(locations.keys) as [GroupUser]).groupUserFrom(email: changedEmail) {
                locations[changedGroupUser] = getLocationFrom(snap: snapshot)
            }
            NotificationCenter.default.post(name: .locationUpdated, object: nil)
        }
        
        //Location Changed
        /*
        ref.observe(.childChanged) { snapshot in
            
            print("child changed")
            //Make sure ride exists
            guard snapshot.exists() else {
                print("no snap exists")
                return
            }
            
            //Reset locations
            self.locations = [:]
            print("object count: \(snapshot.children.allObjects.count)!! if 0, issue when locations are changed in realtime database")
            //Filter through all users and get their locations
            for user in snapshot.children.allObjects as! [DataSnapshot] {
                
                let locationSnap = user.childSnapshot(forPath: "location")
                let userEmail = user.key.fromStorageEmail()
                
                if locationSnap.exists() {
                    
                    let coordinate = getLocationFrom(snap: user)
                    if let groupUser = groupUsers.groupUserFrom(email: userEmail) {
                        self.locations[groupUser] = coordinate
                    } else {
                        print("error getting group user")
                    }
                    
                }
            }
            
            NotificationCenter.default.post(name: .locationUpdated, object: nil)
        }
        */
        //User added to group
        ref.observe(.childAdded) { snapshot in
            print("child added")
            addGroupUser(from: snapshot) { groupUsers, locations  in
                self.groupUsers = groupUsers
                self.locations = locations
                NotificationCenter.default.post(name: .groupUsersUpdated, object: nil)
            }
        }
        
        ref.observe(.childRemoved) { snapshot in
            print("child removed")
            NotificationCenter.default.post(name: .groupUsersUpdated, object: nil)
        }
        
 
    }
    
    
    /// Adds Group User from the updated snapshot of the SINGULAR group user
    /// - Parameters:
    ///   - snap: The SINGLE snapshot of the SINGLE user that was added
    ///   - completion: returns all the users and locations in the group
    static func addGroupUser(from snap: DataSnapshot, completion: (([GroupUser], [GroupUser : CLLocationCoordinate2D]) -> Void)? = nil) {
        StorageRetrieve().getGroupUser(from: snap.key.fromStorageEmail()) { user in
            if let user = user, !groupUsers.contains(user) {
                self.groupUsers.append(user)
                let coordinate = getLocationFrom(snap: snap)
                self.locations[user] = coordinate
            }
            completion?(groupUsers, locations)
        }
    }
    
    /// Filters through a singular persons snapshot and gets the Coordinate
    /// - Parameters:
    ///   - snap: the snapshot of the singular person
    static func getLocationFrom(snap: DataSnapshot) -> CLLocationCoordinate2D {
        let locationDictionary = snap.childSnapshot(forPath: "location").value as! [String : Any]
        let coordinate = CLLocationCoordinate2D(
            latitude: locationDictionary["latitude"] as! CLLocationDegrees,
            longitude: locationDictionary["longitude"] as! CLLocationDegrees)
        return coordinate
    }
    
    static func setGroupUsers(for groupRef: DatabaseReference?, completion: (([GroupUser]) -> Void)? = nil) {
        guard let groupRef = groupRef else { print("oops"); return }
        groupUsers = []
        groupRef.observeSingleEvent(of: .value) { snapshot in
            
            let emails = (snapshot.children.allObjects as! [DataSnapshot]).map { $0.key.fromStorageEmail() }
            StorageRetrieve().getGroupUsers(from: emails) { groupUsers in
                completion?(groupUsers)
            }
            
        }
    }
    
    static func removeNotifications(for group: String) {
        let ref = Database.database().reference().child("rides/" + group)
        ref.removeAllObservers()
    }
    
}
