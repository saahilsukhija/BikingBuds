//
//  AppNotifications.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 10/9/21.
//

import UIKit

struct AppNotification {
    var title: String!
    var subTitle: String?
    var image: UIImage?
    var type: NotificationType!
    
    enum NotificationType {
        case fall
        case distanceTooFar
        case userJoined
        case userLeft
    }
}
