//
//  RoundedButton.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/8/21.
//

import UIKit

class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            updateCornerRadius()
        }
    }
    
    override func awakeFromNib() {
        updateCornerRadius()
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
    }

}
