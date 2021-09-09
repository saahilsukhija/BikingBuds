//
//  ViewShadow.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 9/5/21.
//

import UIKit

extension UIView {

    func dropShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 3.0
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
