//
//  StorageHelpers.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 6/8/21.
//

import UIKit
import FirebaseDatabase
import GoogleSignIn
import Lottie
extension String {
    //MARK: -Email
    func toLegalStorageEmail() -> String {
        return self.replacingOccurrences(of: ".", with: "||", options: .literal)
    }
    
    func fromStorageEmail() -> String {
        return self.replacingOccurrences(of: "||", with: ".", options: .literal)
    }
}

extension UIViewController {
    
    func createLoadingScreen(frame: CGRect, message: String = "", animation: String? = nil) -> UIView {
        
        let loadingScreen = UIView(frame: frame)
        loadingScreen.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        if let animation = animation {
            let animationView = AnimationView(name: animation)
            animationView.center = view.center
            animationView.contentMode = .scaleAspectFill
            animationView.loopMode = .loop
            animationView.play()
            loadingScreen.addSubview(animationView)
        }
        else {
            let loadingIndicator = UIActivityIndicatorView(frame: view.frame)
            loadingIndicator.style = .large
            loadingIndicator.startAnimating()
            loadingScreen.addSubview(loadingIndicator)
        }
        
        let messageView = UILabel(frame: CGRect(x: view.center.x - 100, y: view.center.y + 60, width: 200, height: 50))
        messageView.textAlignment = .center
        messageView.font = UIFont(name: "DIN Alternate Bold", size: 20)
        messageView.text = message
        messageView.numberOfLines = 0
        loadingScreen.addSubview(messageView)
        
        return loadingScreen
    }
    
}

struct HelperFunctions {
    static func encodeToJSON<T: Codable>(_ object: T) throws -> String {
        let data = try JSONEncoder().encode(object)
        return String(decoding: data, as: UTF8.self)
    }
    
    static func decodeFromString<T: Codable>(_ string: String, objectType: T.Type) throws -> T {
        return try JSONDecoder().decode(objectType, from: string.data(using: .utf8)!)
    }
    
    static func makeLegalRiderType(_ riderType: RiderType) -> String {
        switch riderType {
        case .rider:
            return "rider"
        case .spectator:
            return "spectator"
        }
    }
    
    static func toRiderType(_ string: String) -> RiderType? {
        switch string {
        case "rider":
            return .rider
        case "spectator":
            return .spectator
        default:
            return nil
        }
    }
}

extension Date {

    func timeAgoSinceDate() -> String {

        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }

        return "a moment ago"
    }
}
