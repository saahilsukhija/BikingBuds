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
    
}
