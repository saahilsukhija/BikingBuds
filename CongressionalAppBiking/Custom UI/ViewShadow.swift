//
//  ViewShadow.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 9/5/21.
//

import UIKit

extension UIView {

    func dropShadow(radius: CGFloat = 3) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.systemGray.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowRadius = radius/2
        layer.shadowOffset = CGSize(width: 0, height: radius/2)
    }
}
