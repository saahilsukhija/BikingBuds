//
//  RoutePreview.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 12/2/22.
//

import Foundation

struct RWGPSRoutePreview {
    var name: String
    var description: String
    var miles: Double //Meters
    var elevation: Double //Meters
    var createdAt: Date
    var id: String
    
    static func convertToDate(_ str: String) -> Date {

          let dateFormatter = DateFormatter()
          dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
          return dateFormatter.date(from:str) ?? Date()
    }
    
    static func metersToFeet(_ num: Double) -> Double {
        return num * 3.28084
    }
    
    static func metersToMiles(_ num: Double) -> Double {
        return num * 0.000621371
    }
    
}
