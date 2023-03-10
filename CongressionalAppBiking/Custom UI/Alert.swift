//
//  Alert.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/25/21.
//

import UIKit

struct Alert {
    
    static func showDefaultAlert(title: String, message: String, _ vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showSettingsAlert(title: String, message: String, _ vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Later", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.cancel, handler: { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
}
