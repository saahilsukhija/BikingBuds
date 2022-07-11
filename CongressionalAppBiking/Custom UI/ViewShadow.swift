//
//  ViewShadow.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 9/5/21.
//

import UIKit

extension UIView {

    func dropShadow(radius: CGFloat = 3) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
