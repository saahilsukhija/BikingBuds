//
//  AppNotifications.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 10/9/21.
//

import UIKit

struct AppNotification {
    var email: String!
    var title: String!
    var subTitle: String?
    var image: UIImage?
    var type: NotificationType!
    var isRead: Bool = false
    
    enum NotificationType {
        case fall
        case distanceTooFar
        case userJoined
        case userLeft
    }
}

extension Array where Element == AppNotification {
    mutating func addNotification(email: String, title: String, subTitle: String? = nil, image: UIImage? = nil, type: AppNotification.NotificationType) {
        self.insert(AppNotification(email: email, title: title, subTitle: subTitle, image: image, type: type), at: 0)
    }
    
    mutating func addNotification(_ notification: AppNotification) {
        self.insert(notification, at: 0)
    }
    
    func getAllUnreadNotifications() -> [AppNotification] {
        return self.filter { notification in
            return !notification.isRead
        }
    }
    
    func getAllReadNotifications() -> [AppNotification] {
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
    
    func notificationsForEmail(_ email: String) -> [AppNotification]{
        return self.filter { notification in
            return notification.email == email
        }
    }
    func notificationsForEveryoneNotEmail(_ email: String) -> [AppNotification]{
        return self.filter { notification in
            return notification.email != email
        }
    }
}
