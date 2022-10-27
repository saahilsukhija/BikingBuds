//
//  DateFormatterTimeDifference.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 2/12/22.
//

import Foundation

extension Date {
    func timeAgo() -> String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .full
//        formatter.dateTimeStyle = .named
//        formatter.formattingContext = .beginningOfSentence
//        return formatter.localizedString(for: self, relativeTo: Date())
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            return "Now"
            
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "minute"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
    }
}
