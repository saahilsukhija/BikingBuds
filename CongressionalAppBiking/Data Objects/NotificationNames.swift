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
    
    /// Notification when user joins group
    static var groupUsersUpdated: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when user's profile was updated
    static var profileUpdated: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when the current user has switched to non-rider.
    static var userIsNonRider: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when the current user has switched to rider.
    static var userIsRider: Notification.Name {
        return .init(rawValue: #function)
    }
    
    static var userHasFallen: Notification.Name {
        return .init(rawValue: #function)
    }
    
    ///MARK: Bottom Sheet Notifications
    /// Notification when search bar is clicked in the Group Bottom Sheet
    static var searchBarClicked: Notification.Name {
        return .init(rawValue: #function)
    }
    
    
    
    
    
}
