//
//  NotificationNames.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/8/21.
//

import Foundation

extension Notification.Name {
    /// Notification when user successfully sign in using Google
    static var signInGoogleCompleted: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when user's signed in with email/password
    static var signInEmailCompleted: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when user provided extra info
    static var additionalInfoCompleted: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when user's location was updated
    static var locationUpdated: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when user's profile was updated
    static var profileUpdated: Notification.Name {
        return .init(rawValue: #function)
    }
    
    
    
}
