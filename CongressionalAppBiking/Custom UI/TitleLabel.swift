//
//  TitleLabel.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/5/21.
//

import UIKit

class TitleLabel: UILabel {

    override func awakeFromNib() {
        updateText()
    }
    
    func updateText() {
        let mutableTitle = NSMutableAttributedString(string: self.text!, attributes: [NSAttributedString.Key.font : UIFont(name: "Baumans", size: 38)!])
        mutableTitle.setColor(color: .accentColor, forText: "Buds")
        self.attributedText = mutableTitle
    }

}
