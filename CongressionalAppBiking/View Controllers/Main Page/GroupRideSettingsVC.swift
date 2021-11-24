//
//  GroupRideSettingsVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 9/7/21.
//

import UIKit

class GroupRideSettingsVC: UIViewController {
 
    var ride: Ride!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveThisRide(_ sender: Any) {
        var previousSavedRides: [Ride] = []
        do {
            previousSavedRides = try UserDefaults.standard.get(objectType: [Ride].self, forKey: "saved_rides") ?? []
        } catch {
            self.showFailureToast(message: "Error saving ride")
            return
        }
        
        guard !previousSavedRides.containsRide(ride) else {
            self.showFailureToast(message: "Ride is already saved.")
            return
        }
        
        previousSavedRides.append(ride)
        self.showSuccessToast(message: "Ride is saved!")
        
        try? UserDefaults.standard.set(object: previousSavedRides, forKey: "saved_rides")
        print(previousSavedRides)
        
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
