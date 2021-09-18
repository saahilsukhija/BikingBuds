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
    static var lastUpdated: [GroupUser : String]! = [:]
    static var riderTypes: [GroupUser : RiderType]! = [:]
    static var groupUsers: [GroupUser]! = []
    
    //static var groupID: String?
    ///Add notifications for user locations updating in a group
    static func addNotifications(for group: String) {
        
        //Reset all
        locations.removeAll()
        lastUpdated.removeAll()
        riderTypes.removeAll()
        groupUsers.removeAll()
        
        let ref = Database.database().reference().child("rides/" + group)
        
        ref.observe(.childChanged) { snapshot in
            
            let changedEmail = snapshot.key.fromStorageEmail()
            if let changedGroupUser = (Array(locations.keys) as [GroupUser]).groupUserFrom(email: changedEmail) {
                locations[changedGroupUser] = getLocationFrom(snap: snapshot)
                lastUpdated[changedGroupUser] = getLastUpdatedFrom(snap: snapshot)
                riderTypes[changedGroupUser] = getRiderType(snap: snapshot)
                NotificationCenter.default.post(name: .locationUpdated, object: nil)
            }
        }

        //User added to group
        ref.observe(.childAdded) { snapshot in
            print("child added")
            addGroupUser(from: snapshot) { groupUsers, locations, lastUpdated, riderTypes in
                self.groupUsers = groupUsers
                self.locations = locations
                self.lastUpdated = lastUpdated
                self.riderTypes = riderTypes
                NotificationCenter.default.post(name: .groupUsersUpdated, object: nil)
            }
        }
        
        ref.observe(.childRemoved) { snapshot in
            NotificationCenter.default.post(name: .groupUsersUpdated, object: nil)
        }
        
 
    }
    
    /// Adds Group User from the updated snapshot of the SINGULAR group user
    /// - Parameters:
    ///   - snap: The SINGLE snapshot of the SINGLE user that was added
    ///   - completion: returns all the users, locations, lastUpdated, riderTypes in the group
    static func addGroupUser(from snap: DataSnapshot, completion: (([GroupUser], [GroupUser : CLLocationCoordinate2D], [GroupUser : String], [GroupUser : RiderType]) -> Void)? = nil) {
        StorageRetrieve().getGroupUser(from: snap.key.fromStorageEmail()) { user in
            if let user = user, !groupUsers.contains(user) {
                self.groupUsers.append(user)
                let coordinate = getLocationFrom(snap: snap)
                let lastUpdated = getLastUpdatedFrom(snap: snap)
                let riderType = getRiderType(snap: snap)
                self.locations[user] = coordinate
                self.lastUpdated[user] = lastUpdated
                self.riderTypes[user] = riderType
            }
            completion?(groupUsers, locations, lastUpdated, riderTypes)
        }
    }
    
    
    /// Adds ALL GroupUsers from a groupSnapshot
    /// - Parameters:
    ///   - groupRef: The groupSnapshot ("rides/{id}")
    ///   - completion: returns all the properties.
    static func addGroupUsers(from groupSnapshot: DataSnapshot, completion: (([GroupUser], [GroupUser : CLLocationCoordinate2D], [GroupUser : String], [GroupUser : RiderType]) -> Void)? = nil) {
        let allUserSnapshots = groupSnapshot.children.allObjects as! [DataSnapshot]
        let emails = allUserSnapshots.map { $0.key.fromStorageEmail() }
        
        StorageRetrieve().getGroupUsers(from: emails) { groupUsers in
            for user in groupUsers {
                if !groupUsers.contains(user) {
                    self.groupUsers.append(user)
                    
                    let userSnap = groupSnapshot.childSnapshot(forPath: user.email.toLegalStorageEmail())
                    let coordinate = getLocationFrom(snap: userSnap)
                    let lastUpdated = getLastUpdatedFrom(snap: userSnap)
                    let riderType = getRiderType(snap: userSnap)
                    self.locations[user] = coordinate
                    self.lastUpdated[user] = lastUpdated
                    self.riderTypes[user] = riderType
                }
            }
            completion?(self.groupUsers, locations, lastUpdated, riderTypes)
        }
    }
    
    /// Filters through a singular persons snapshot and gets the Coordinate
    /// - Parameters:
    ///   - snap: the snapshot of the singular person
    static func getLocationFrom(snap: DataSnapshot) -> CLLocationCoordinate2D {
        guard let locationDictionary = snap.childSnapshot(forPath: "location").value as? [String : Any] else {
            return CLLocationCoordinate2DMake(0, 0)
        }
        let coordinate = CLLocationCoordinate2D(
            latitude: locationDictionary["latitude"] as! CLLocationDegrees,
            longitude: locationDictionary["longitude"] as! CLLocationDegrees)
        return coordinate
    }
    
    /// Filters through a singular persons snapshot and gets the Last Updated Time
    /// - Parameters:
    ///   - snap: the snapshot of the singular person
    static func getLastUpdatedFrom(snap: DataSnapshot) -> String {
        guard let locationDictionary = snap.childSnapshot(forPath: "location").value as? [String : Any] else {
            return "N/A"
        }
        return locationDictionary["last_updated"] as! String
    }
    
    /// Filters through a singular persons snapshot and gets the Rider Type
    /// - Parameters:
    ///   - snap: the snapshot of the singular person
    static func getRiderType(snap: DataSnapshot) -> RiderType {
        guard let riderType = snap.childSnapshot(forPath: "rider_type").value as? String else {
            return .spectator
            
        }
        
        return HelperFunctions.toRiderType(riderType) ?? .spectator
    }
    
    static func resetGroupUsers(for group: String) {
        //Reset all
        locations.removeAll()
        lastUpdated.removeAll()
        riderTypes.removeAll()
        groupUsers.removeAll()
        
        let ref = Database.database().reference().child("rides/" + group)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            addGroupUsers(from: snapshot) { groupUsers, locations, lastUpdated, riderTypes in
                self.groupUsers = groupUsers
                self.locations = locations
                self.lastUpdated = lastUpdated
                self.riderTypes = riderTypes
                print("reseted")
                NotificationCenter.default.post(name: .groupUsersUpdated, object: nil)
            }
        }
    }
    
    static func removeNotifications(for group: String) {
        let ref = Database.database().reference().child("rides/" + group)
        ref.removeAllObservers()
    }
    
}
