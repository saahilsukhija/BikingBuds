//
//  UserSettings.swift
//  Property Management
//
//  Created by Saahil Sukhija on 3/29/24.
//

import Foundation


class UserSettings: Codable {
    
    //Singleton Instance
    static let shared: UserSettings = {
        let instance = UserSettings()
        return instance
    }()
    
    private(set) var lowPowerModeEnabled: Bool! = false
    private(set) var showInitialsOnMap: Bool! = true
    private(set) var mapType: MapType! = .standard
    init() {
        do {
            let s = try UserDefaults.standard.get(objectType: UserSettings.self, forKey: "user_settings")
            self.lowPowerModeEnabled = s?.lowPowerModeEnabled ?? false
            self.showInitialsOnMap = s?.showInitialsOnMap ?? true
            self.mapType = s?.mapType ?? .standard
        } catch {
            self.lowPowerModeEnabled = false
            self.showInitialsOnMap = true
            self.mapType = .standard
            print("no user settings available.")
        }
        save()
    }
    
    func enableLowPowerMode(_ shouldEnable: Bool = true) {
        self.lowPowerModeEnabled = shouldEnable
        if !shouldEnable {
            lowPowerModeEnabled = false
        }
        
        Preferences.shared.enableLowPowerMode(self.lowPowerModeEnabled)
        NotificationCenter.default.post(name: .lowPowerModeEnabled, object: nil)
        save()
    }
    
    func showInitials(_ shouldEnable: Bool = true) {
        self.showInitialsOnMap = shouldEnable
        if !shouldEnable {
            showInitialsOnMap = false
        }
        save()
    }
    
    func changeMapType(_ type: MapType) {
        self.mapType = type
        save()
    }
    
    func save() {
        do {
            try UserDefaults.standard.set(object: self, forKey: "user_settings")
        } catch {}
    }
    
    
    enum MapType: Codable {
        case hybrid
        case satellite
        case standard
        
    }
    
    
}
