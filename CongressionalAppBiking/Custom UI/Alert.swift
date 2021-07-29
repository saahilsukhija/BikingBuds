//
//  Alert.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/25/21.
//

import UIKit

struct Alert {
    
    static func showDefaultAlert(title: String, message: String, _ vc: UIViewController) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.present(alertViewController, animated: true, completion: nil)
    }
    
}
