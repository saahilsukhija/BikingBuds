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
    
    static func addProfileChangesNotification() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                print("userchanged, \(user.email!), \(user.displayName!)")
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
    
    static func userExists(_ user: GIDGoogleUser) {
        
    }
    
    
    
}
