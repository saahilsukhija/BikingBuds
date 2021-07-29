//
//  User.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/8/21.
//

import UIKit
import GoogleSignIn

class User : Codable {
    static var firstName: String!
    static var lastName: String!
    static var email: String!
    static var phoneNumber: String!
    static var profilePicture: UIImage?
    
    static func setUpUser(_ user: GIDGoogleUser) {
        let profile = user.profile!
        self.firstName = profile.givenName
        self.lastName = profile.familyName
        self.email = profile.email
    }
    
}
