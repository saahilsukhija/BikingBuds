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
    static var lastUpdated: [GroupUser : Date?]! = [:]
    static var riderTypes: [GroupUser : RiderType]! = [:]
    static var groupUsers: [GroupUser]! = []
    static var deviceTokens: [GroupUser : String]! = [:]
    
    static var falls: [String : Date] = [:]
    static var recentFall: [String : Date] = [:]
    
    static var notifications: [AppNotification] = []
    static var announcementNotifications: [AnnouncementNotification] = []
    
    
    //static var groupID: String?
    ///Add notifications for user locations updating in a group
    static func addNotifications(for group: String) {
        
        //Reset all
        locations.removeAll()
        lastUpdated.removeAll()
        riderTypes.removeAll()
        groupUsers.removeAll()
        announcementNotifications.removeAll()
        deviceTokens.removeAll()
        
        let ref = Database.database().reference().child("rides/" + group)
        
        ref.observe(.childChanged) { snapshot in
            
            let changedEmail = snapshot.key.fromStorageEmail()
            if let changedGroupUser = (Array(locations.keys) as [GroupUser]).groupUserFrom(email: changedEmail) {
                locations[changedGroupUser] = getLocationFrom(snap: snapshot)
                lastUpdated[changedGroupUser] = getLastUpdatedFrom(snap: snapshot)
                riderTypes[changedGroupUser] = getRiderType(snap: snapshot)
                deviceTokens[changedGroupUser] = getDeviceToken(snap: snapshot)
                NotificationCenter.default.post(name: .locationUpdated, object: nil)
            }
        }
        
        //User added to group
        ref.observe(.childAdded) { snapshot in
            print("child added")
            addGroupUser(from: snapshot) { wasCompleted, groupUsers, locations, lastUpdated, riderTypes, deviceTokens in
                self.groupUsers = groupUsers
                self.locations = locations
                self.lastUpdated = lastUpdated
                self.riderTypes = riderTypes
                self.deviceTokens = deviceTokens
                
                if wasCompleted {
                    let email = snapshot.key.fromStorageEmail()
                    if email != Authentication.user?.email {
                        
                        self.notifications.addNotification(email: email, title: "\(self.groupUsers.groupUserFrom(email: email)?.displayName ?? "someone") has joined", type: .userJoined)
                    }
                    NotificationCenter.default.post(name: .groupUsersUpdated, object: nil)
                    
                }
            }
        }
        
        ref.observe(.childRemoved) { snapshot in
            let email = snapshot.key.fromStorageEmail()
            if email != Authentication.user?.email {
                removeGroupUser(from: snapshot) { wasCompleted, groupUsers, locations, lastUpdated, riderTypes, deviceTokens, name in
                    self.groupUsers = groupUsers
                    self.locations = locations
                    self.lastUpdated = lastUpdated
                    self.riderTypes = riderTypes
                    self.deviceTokens = deviceTokens
                    
                    if wasCompleted {
                        let email = snapshot.key.fromStorageEmail()
                        if email != Authentication.user?.email {
                            
                            self.notifications.addNotification(email: email, title: "\(name) has left", type: .userLeft)
                        }
                        NotificationCenter.default.post(name: .groupUsersUpdated, object: nil)
                        NotificationCenter.default.post(name: .shouldResetMapAnnotations, object: nil)
                    }
                }
            }
        }
        
        
    }
    
    /// Adds Group User from the updated snapshot of the SINGULAR group user
    /// - Parameters:
    ///   - snap: The SINGLE snapshot of the SINGLE user that was added
    ///   - completion: returns all the users, locations, lastUpdated, riderTypes in the group
    static func addGroupUser(from snap: DataSnapshot, completion: ((Bool, [GroupUser], [GroupUser : CLLocationCoordinate2D], [GroupUser : Date?], [GroupUser : RiderType], [GroupUser : String]) -> Void)? = nil) {
        StorageRetrieve().getGroupUser(from: snap.key.fromStorageEmail()) { user in
            if let user = user, !groupUsers.contains(user) {
                self.groupUsers.append(user)
                let coordinate = getLocationFrom(snap: snap)
                let lastUpdated = getLastUpdatedFrom(snap: snap)
                let riderType = getRiderType(snap: snap)
                let deviceToken = getDeviceToken(snap: snap)
                self.locations[user] = coordinate
                self.lastUpdated[user] = lastUpdated
                self.riderTypes[user] = riderType
                self.deviceTokens[user] = deviceToken
                completion?(true, groupUsers, locations, self.lastUpdated, riderTypes, self.deviceTokens)
            } else {
                completion?(false, groupUsers, locations, lastUpdated, riderTypes, self.deviceTokens)
            }
        }
    }
    
    
    /// Adds ALL GroupUsers from a groupSnapshot
    /// - Parameters:
    ///   - groupRef: The groupSnapshot ("rides/{id}")
    ///   - completion: returns all the properties.
    static func addGroupUsers(from groupSnapshot: DataSnapshot, completion: (([GroupUser], [GroupUser : CLLocationCoordinate2D], [GroupUser : Date?], [GroupUser : RiderType], [GroupUser : String]) -> Void)? = nil) {
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
                    let deviceToken = getDeviceToken(snap: userSnap)
                    
                    self.locations[user] = coordinate
                    self.lastUpdated[user] = lastUpdated
                    self.riderTypes[user] = riderType
                    self.deviceTokens[user] = deviceToken
                }
            }
            completion?(self.groupUsers, locations, lastUpdated, riderTypes, deviceTokens)
        }
    }
    
    static func removeGroupUser(from snap: DataSnapshot, completion: ((Bool, [GroupUser], [GroupUser : CLLocationCoordinate2D], [GroupUser : Date?], [GroupUser : RiderType], [GroupUser : String], String) -> Void)? = nil) {
        StorageRetrieve().getGroupUser(from: snap.key.fromStorageEmail()) { user in
            if let user = user, groupUsers.contains(user), let index = groupUsers.firstIndex(of: user) {
                let name = user.displayName
                self.groupUsers.remove(at: index)
                self.locations.removeValue(forKey: user)
                self.lastUpdated.removeValue(forKey: user)
                self.riderTypes.removeValue(forKey: user)
                self.deviceTokens.removeValue(forKey: user)
                completion?(true, groupUsers, locations, self.lastUpdated, riderTypes, deviceTokens, name ?? "someone")
            } else {
                completion?(false, groupUsers, locations, lastUpdated, riderTypes, deviceTokens, "someone")
            }
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
    static func getLastUpdatedFrom(snap: DataSnapshot) -> Date? {
        guard let locationDictionary = snap.childSnapshot(forPath: "location").value as? [String : Any] else {
            return nil
        }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = df.date(from: locationDictionary["last_updated"] as! String)
        return date
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
    
    static func getDeviceToken(snap: DataSnapshot) -> String {
        guard let token = snap.childSnapshot(forPath: "device_token").value as? String else {
            return ""
            
        }
        
        return token
    }
    
    static func resetGroupUsers(for group: String) {
        //Reset all
        locations.removeAll()
        lastUpdated.removeAll()
        riderTypes.removeAll()
        groupUsers.removeAll()
        
        let ref = Database.database().reference().child("rides/" + group)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            addGroupUsers(from: snapshot) { groupUsers, locations, lastUpdated, riderTypes, deviceTokens in
                self.groupUsers = groupUsers
                self.locations = locations
                self.lastUpdated = lastUpdated
                self.riderTypes = riderTypes
                self.deviceTokens = deviceTokens
                print("reseted")
                NotificationCenter.default.post(name: .groupUsersUpdated, object: nil)
            }
        }
    }
    
    static func removeNotifications(for group: String) {
        let ref = Database.database().reference().child("rides/" + group)
        ref.removeAllObservers()
    }
    
    static func removeAnnouncementObservers(for group: String) {
        let ref = Database.database().reference().child("rides/" + group + "/announcements")
        ref.removeAllObservers()
    }
    
    
    static func addNotificationsForFallDetection(for group: String) {
        let ref = Database.database().reference().child("rides/" + group + "/fall")
        ref.observe(.value) { snap in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            guard snap.children.allObjects.count > 0 else { return }
            guard let snapValue = (snap.children.allObjects[0] as? DataSnapshot)?.value as? String else {
                print(snap.key);
                print(snap.value as Any)
                print((snap.children.allObjects[0] as? DataSnapshot)?.value as Any)
                return
            }
            if let time = dateFormatter.date(from: snapValue), let email = (snap.children.allObjects[0] as? DataSnapshot)?.key.fromStorageEmail() {
                
                self.falls[email] = time
                self.recentFall = [email : time]
                print("hello")
                let diffInMinutes = Calendar.current.dateComponents([.minute], from: time, to: Date()).minute ?? 0
                if  diffInMinutes <= 2 {
                    print("oops")
                    if email != Authentication.user?.email {
                        print("damnn")
                        self.notifications.addNotification(email: email, title: "\(self.groupUsers.groupUserFrom(email: email)?.displayName ?? "\(email)") has fallen!", subTitle: "Call their emergency contact!", type: .fall)
                    }
                    NotificationCenter.default.post(name: .userHasFallen, object: nil)
                } else {
                    print(diffInMinutes)
                    if #available(iOS 15.0, *) {
                        print(time.ISO8601Format())
                    } else {
                        // Fallback on earlier versions
                    }
                    print(time)
                }
            }
        }
    }
    
    static func addNotificationsForAnnouncements(for group: String) {
        let ref = Database.database().reference().child("rides/" + group + "/announcements")
        
        ref.observe(.childAdded) { snap in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            guard snap.children.allObjects.count > 0 else { return }
            guard let snapDict = snap.value as? Dictionary<String, String> else {
                print(snap.key);
                print(snap.value as Any)
                print((snap.children.allObjects[0] as? DataSnapshot)?.value as Any)
                return
            }
            print(snapDict)
            if let time = dateFormatter.date(from: snapDict["uploaded"] ?? ""), let email = snapDict["user"]?.fromStorageEmail(), let announcement = snapDict["announcement"] {
                let diffInMinutes = Calendar.current.dateComponents([.minute], from: time, to: Date()).minute ?? 0
                if  diffInMinutes <= 5 {
                    self.announcementNotifications.addNotification(email: email, title: "\(announcement)", time: time)
                    NotificationCenter.default.post(name: .newAnnouncement, object: nil)
                    
                    if email != Authentication.user?.email {
                        //print("email: \(email)   Authentication.user.email: \(Authentication.user?.email)")
                        if #available(iOS 15.0, *) {
                            print(time.ISO8601Format())
                        } else {
                            // Fallback on earlier versions
                        }
//                        self.announcementNotifications.addNotification(email: email, title: "\(announcement)", time: time)
//                        NotificationCenter.default.post(name: .newAnnouncement, object: nil)
                    }
                } else {
                    print(diffInMinutes)
                    if #available(iOS 15.0, *) {
                        print(time.ISO8601Format())
                    } else {
                        // Fallback on earlier versions
                    }
                    print(time)
                }
            }
//            if let time = dateFormatter.date(from: snapValue), let email = (snap.children.allObjects[0] as? DataSnapshot)?.key.fromStorageEmail() {
//
//                self.falls[email] = time
//                self.recentFall = [email : time]
//                print("hello")
//                let diffInMinutes = Calendar.current.dateComponents([.minute], from: time, to: Date()).minute ?? 0
//                if  diffInMinutes <= 2 {
//                    print("oops")
//                    if email != Authentication.user?.email {
//                        print("damnn")
//                        self.notifications.addNotification(email: email, title: "\(self.groupUsers.groupUserFrom(email: email)?.displayName ?? "\(email)") has fallen!", subTitle: "Call their emergency contact!", type: .fall)
//                    }
//                    NotificationCenter.default.post(name: .userHasFallen, object: nil)
//                } else {
//                    print(diffInMinutes)
//                    if #available(iOS 15.0, *) {
//                        print(time.ISO8601Format())
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                    print(time)
//                }
//            }
        }
    }
}
