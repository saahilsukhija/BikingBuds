//
//  Preferences.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/28/21.
//

import UIKit

class Preferences: Codable {
    
    //Singleton Instance
    static let shared: Preferences = {
        let instance = Preferences()
        return instance
    }()
    
    static let coordinateRoundTo = 4
    var distanceFilter: Double = 15.0 // Keep as a double
    var timeFilter: Double = 120
    
    init() {
        do {
            let s = try UserDefaults.standard.get(objectType: Preferences.self, forKey: "user_preferences")
            self.distanceFilter = s?.distanceFilter ?? Constants.normal_distanceFilter
            self.timeFilter = s?.timeFilter ?? Constants.normal_timeInterval
            
        } catch {
            self.distanceFilter = Constants.normal_distanceFilter
            self.timeFilter = Constants.normal_timeInterval
            print("no user preferences available.")
        }
        save()
    }
    
    func enableLowPowerMode(_ shouldEnable: Bool = true) {
        if shouldEnable {
            self.distanceFilter = Constants.lowPowerMode_distanceFilter
            self.timeFilter = Constants.lowPowerMode_timeInterval
        } else {
            self.distanceFilter = Constants.normal_distanceFilter
            self.timeFilter = Constants.normal_timeInterval
        }
    }
    
    
    func save() {
        do {
            try UserDefaults.standard.set(object: self, forKey: "user_preferences")
        } catch {}
    }
    

    
}
