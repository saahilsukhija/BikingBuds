//
//  AuthenticationHelpers.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/5/21.
//

import UIKit
import GoogleSignIn
import FirebaseStorage
import FirebaseAuth

struct Authentication {
    static var user: User?
    static var phoneNumber: String?
    static var emergencyPhoneNumber: String?
    ///Path to image, for example: "pictures/bob@gmail.com"
    static var imagePath: String?
    
    static var image: UIImage?
    
    static var riderType: RiderType?
    
    static var deviceToken: String?
    
    static func addProfileChangesNotification() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.user = user
                Auth.auth().updateCurrentUser(user, completion: nil)
            }
            NotificationCenter.default.post(name: .AuthStateDidChange, object: nil)
        }
    }
    
    static func hasPreviousSignIn() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
        return false
    }
    
    static func getUser() -> User {
        return Auth.auth().currentUser!
    }
    
    
    /// Turns an auth user into a storage friendly user
    /// - Parameter currentUser: The current Auth.auth().currentUser, defaults to Auth.auth().user!
    /// - Returns: The GroupUser
    static func turnIntoGroupUser(_ currentUser: User = Auth.auth().currentUser!, phoneNumber: String?, emergencyPhoneNumber: String? = nil) -> GroupUser {
        let groupUser = GroupUser(id: currentUser.uid, displayName: currentUser.displayName!, email: currentUser.email!, phoneNumber: phoneNumber ?? "N/A", emergencyPhoneNumber: emergencyPhoneNumber ?? "N/A", profilePicturePath: imagePath)
        return groupUser
    }
    
    
    
}
