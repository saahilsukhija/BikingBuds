//
//  AnnouncementNotification.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 6/23/22.
//

import UIKit

struct AnnouncementNotification {
    var email: String!
    var title: String!
    var time: Date!
    var image: UIImage?
    var isRead: Bool = false

}

extension Array where Element == AnnouncementNotification {
    mutating func addNotification(email: String, title: String, time: Date, image: UIImage? = nil) {
        self.addNotification(AnnouncementNotification(email: email, title: title, time: time, image: image))
    }
    
    mutating func addNotification(_ notification: AnnouncementNotification) {
        let (notificationExists, notificationIndex) = notificationAlreadyExists(notification)
        if notificationExists {
            print("repeat notification: \(notification.title ?? "error")")
            self.remove(at: notificationIndex)
        }
        self.insert(notification, at: 0)
    }
    
    func getAllUnreadNotifications() -> [AnnouncementNotification] {
        return self.filter { notification in
            return !notification.isRead
        }
    }
    
    func getAllReadNotifications() -> [AnnouncementNotification] {
        return self.filter { notification in
            return notification.isRead
        }
    }
    
    mutating func markAllNotificationsAsRead() {
        for var notification in self {
            notification.isRead = true
        }
    }
    
    mutating func markAllNotificationsAsUnread() {
        for var notification in self {
            notification.isRead = false
        }
    }
    
    func notificationsForEmail(_ email: String) -> [AnnouncementNotification]{
        return self.filter { notification in
            return notification.email == email
        }
    }
    func notificationsForEveryoneNotEmail(_ email: String) -> [AnnouncementNotification]{
        return self.filter { notification in
            return notification.email != email
        }
    }
    
    func notificationAlreadyExists(_ notification: AnnouncementNotification) -> (Bool, Int) {
        for (index, notif) in self.enumerated() {
            if notif.email == notification.email && notif.title == notification.title && notif.time == notification.time {
                return (true, index)
            }
        }
        
        return (false, -1)
    }
    
    func otherUsersAnnouncements() -> [AnnouncementNotification] {
        var announcements: [AnnouncementNotification] = []
        guard let email = Authentication.user?.email else { return [] }
        
        for announcement in self {
            if announcement.email.fromStorageEmail() != email.fromStorageEmail() {
                announcements.append(announcement)
            }
        }
        return announcements
    }
    
    func myAnnouncements() -> [AnnouncementNotification] {
        var announcements: [AnnouncementNotification] = []
        guard let email = Authentication.user?.email else { return [] }
        
        for announcement in self {
            if announcement.email.fromStorageEmail() == email.fromStorageEmail() {
                announcements.append(announcement)
            }
        }
        return announcements
    }
    
    mutating func sortByTimeDescending() {
//        self = self.sorted(by: {
//            $0.time.compare($1.time) == .orderedDescending
//        })
    }
}
