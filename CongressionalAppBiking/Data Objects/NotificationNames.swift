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
    
    //SOMEONE ELSE IN GROUP
    static var userHasFallen: Notification.Name {
        return .init(rawValue: #function)
    }
    
    //CURRENT USER
    static var currentUserHasFallen: Notification.Name {
        return .init(rawValue: #function)
    }
    
    static var userIsTooFar: Notification.Name {
        return .init(rawValue: #function)
    }
    
    static var userClickedOnJoinLink: Notification.Name {
        return .init(rawValue: #function)
    }
    ///MARK: Bottom Sheet Notifications
    /// Notification when search bar is clicked in the Group Bottom Sheet
    static var searchBarClicked: Notification.Name {
        return .init(rawValue: #function)
    }
    ///Used primarily for when a user leaves
    static var shouldResetMapAnnotations: Notification.Name {
        return .init(rawValue: #function)
    }
    
    ///Announcement has been published
    static var newAnnouncement: Notification.Name {
        return .init(rawValue: #function)
    }
    
    ///Used in app delegate once device token has been loaded
    static var deviceTokenLoaded: Notification.Name {
        return .init(rawValue: #function)
    }
    
    static var rwgpsUserLogin: Notification.Name {
        return .init(rawValue: #function)
    }
    
    ///Ride With GPS Route has Loaded
    static var rwgpsRouteLoaded: Notification.Name {
        return .init(rawValue: #function)
    }
    
    ///User has had their Ride With GPS Route removed
    static var rwgpsRouteRemoved: Notification.Name {
        return .init(rawValue: #function)
    }
    
    ///Group has had their Ride With GPS Route updated
    static var rwgpsUpdatedInGroup: Notification.Name {
        return .init(rawValue: #function)
    }
    
    static var mapIconPreferenceChanged: Notification.Name {
        return .init(rawValue: #function)
    }
    
    static var mapTypePreferenceChanged: Notification.Name {
        return .init(rawValue: #function)
    }
    
    static var lowPowerModeEnabled: Notification.Name {
        return .init(rawValue: #function)
    }
    
    
    
    
}
