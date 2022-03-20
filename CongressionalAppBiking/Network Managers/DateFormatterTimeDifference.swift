//
//  DateFormatterTimeDifference.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 2/12/22.
//

import Foundation

extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
