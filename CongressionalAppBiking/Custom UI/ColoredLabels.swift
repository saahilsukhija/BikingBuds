//
//  ColoredLabels.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/26/21.
//

import UIKit

// An attributed string extension to achieve colors on text.
extension NSMutableAttributedString {

    func setColor(color: UIColor, forText stringValue: String) {
        let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
    
    func addUnderline(forText stringValue: String) {
        let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single, range: range)
    }

}
