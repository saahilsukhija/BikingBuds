//
//  LocationManager.swift
//  LocationManager
//
//  Created by Rajan Maheshwari on 22/10/16.
//  Copyright © 2016 Rajan Maheshwari. All rights reserved.
//

import UIKit
import MapKit
import CoreMotion

final class FallDetectionManager: NSObject {
    private var motionManager: CMMotionManager?
    private var lastActivity: CMMotionActivity?
    
    private var consecutiveFallFlags = 0
    
    //Singleton Instance
    static let shared: FallDetectionManager = {
        let instance = FallDetectionManager()
        // setup code
        return instance
    }()
    
    //private override init() {}
    
    //MARK:- Destroy the LocationManager
    deinit {
        destroyActivityManager()
    }
    
    private func setupActivityManager() {
        //print("setting up!")
        motionManager = CMMotionManager()
        consecutiveFallFlags = 0
        motionManager?.accelerometerUpdateInterval = 1/15.0
        motionManager?.startAccelerometerUpdates(to: OperationQueue.main, withHandler: { data, error in
            self.motionActivityDidUpdate(with: data, error: error)
        })
    }
    
    private func destroyActivityManager() {
        motionManager = nil
    }
    
    func stopTracking() {
        print("stopped tracking location")
        motionManager?.stopAccelerometerUpdates()
    }
    
    func startTracking() {
        print("started tracking")
        setupActivityManager()
    }
    
}

extension FallDetectionManager: CLLocationManagerDelegate {
    
    func motionActivityDidUpdate(with data: CMAccelerometerData?, error: Error?) {
        guard let data = data else {
            print(error?.localizedDescription ?? "(error getting accelerometer data)")
            return
        }
        
        let acceleration = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
        
        if 9 < acceleration && acceleration < 11 {
            consecutiveFallFlags += 1
        }
        else {
            consecutiveFallFlags = 0
        }
        
        if consecutiveFallFlags > 3 {
            print("fall")
            NotificationCenter.default.post(name: .currentUserHasFallen, object: nil)
        }
        //print("motion did update: \(acceleration)")
    }
    
}

