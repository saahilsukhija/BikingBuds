//
//  User.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/8/21.
//

import UIKit

class GroupUser : Codable, Hashable {
    
    var id: String!
    var displayName: String!
    var email: String!
    var phoneNumber: String!
    var emergencyPhoneNumber: String?
    var profilePicturePath: String?
    var profilePicture: Data?
    
    init(id: String, displayName: String, email: String, phoneNumber: String, emergencyPhoneNumber: String? = nil, profilePicturePath: String? = nil, profilePicture: Data? = nil) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.phoneNumber = phoneNumber
        self.emergencyPhoneNumber = emergencyPhoneNumber
        self.profilePicturePath = profilePicturePath
    }
    
    ///Turns GroupUser to data to upload to storage
    func toData() -> Data {
        profilePicture = nil
        let data = try! JSONEncoder().encode(self)
        return data
    }
    
    static func == (lhs: GroupUser, rhs: GroupUser) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        return false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(displayName)
        hasher.combine(email)
        hasher.combine(phoneNumber)
        hasher.combine(emergencyPhoneNumber)
        hasher.combine(profilePicture)
    }
}

extension Array where Element == GroupUser {
    
    ///Get the user from this array who's email is the one in the parameter. If none exist, returns nil.
    func groupUserFrom(email: String) -> GroupUser? {
        for user in self {
            if user.email == email {
                return user
            }
        }
        
        return nil
    }
    
    func getNames() -> [String] {
        var names: [String] = []
        for user in self {
            names.append(user.displayName)
        }
        return names
    }
    
    func getEmails() -> [String] {
        var emails: [String] = []
        for user in self {
            emails.append(user.email)
        }
        return emails
    }

    
    func groupUser(from name: String) -> GroupUser? {
        for user in self {
            if user.displayName?.lowercased() == name.lowercased() {
                return user
            }
        }
        
        return nil
    }
    
    func groupUsers(from names: [String]) -> [GroupUser]? {
        var groupUsers: [GroupUser] = []
        for user in self {
            if names.contains(where: { name in
                return user.displayName.lowercased() == name.lowercased()
            }) {
                groupUsers.append(user)
            }
        }
        
        return groupUsers
    }
    
    func filterRiders(riders: [GroupUser]) -> [GroupUser] {
        var groupUsers: [GroupUser] = []
        for user in self {
            if riders.getEmails().contains(where: { email in
                return user.email.lowercased() == email.lowercased()
            }) {
                groupUsers.append(user)
            }
        }
        
        return groupUsers
    }
    
    func filterNonRiders(nonRiders: [GroupUser]) -> [GroupUser] {
        var groupUsers: [GroupUser] = []
        for user in self {
            if nonRiders.getEmails().contains(where: { email in
                return user.email.lowercased() == email.lowercased()
            }) {
                groupUsers.append(user)
            }
        }
        
        return groupUsers
    }
}

extension Data {
    func toImage() -> UIImage? {
        return UIImage(data: self)
    }
}

enum GroupUserStatus: Codable, Hashable {
    case stopped
    case notUpdated
    case moving
}
