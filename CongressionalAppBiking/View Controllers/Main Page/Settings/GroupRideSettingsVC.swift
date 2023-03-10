//
//  GroupRideSettingsVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 9/7/21.
//

import UIKit

class GroupRideSettingsVC: UIViewController {
 
    var ride: Ride!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var connectWithRWGPSView: UIView!
    @IBOutlet weak var rwgpsConnectLabel: UILabel!
    
    @IBOutlet weak var versionNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSaveButton()
        setupRWGPSView()
        setupVersionLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(rwgpsRouteSelected), name: .rwgpsRouteLoaded, object: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func rwgpsRouteSelected() {
        self.dismiss(animated: true)
    }
    
    func setupVersionLabel() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionNumberLabel.text = "version \(appVersion ?? "(error)")"
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

//MARK: RWGPS:
extension GroupRideSettingsVC {
    func setupRWGPSView() {
        connectWithRWGPSView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rwgpsViewTapped))
        connectWithRWGPSView.addGestureRecognizer(gestureRecognizer)
        
        connectWithRWGPSView.layer.cornerRadius = 10
        connectWithRWGPSView.layer.borderColor = UIColor.black.cgColor
        connectWithRWGPSView.layer.borderWidth = 1.5
        
        if RWGPSRoute.connected == true {
            rwgpsConnectLabel.text = "Change the RideWithGPS Route"
        } else {
            rwgpsConnectLabel.text = "Connect With RideWithGPS"
        }
    }
    
    @objc func rwgpsViewTapped() {
        if RWGPSUser.hasEmailAndPasswordStored() {
            let loadingScreen = createLoadingScreen(frame: view.frame)
            RWGPSUser.login { completed, message in
                DispatchQueue.main.async {
                    loadingScreen.removeFromSuperview()
                    if !completed {
                        let vc = UIStoryboard(name: "RWGPS", bundle: nil).instantiateViewController(withIdentifier: "RWGPSLoginScreen") as! RWGPSLoginVC
                        self.present(vc, animated: true)
                    } else {
                        let vc = UIStoryboard(name: "RWGPS", bundle: nil).instantiateViewController(withIdentifier: "RWGPSSelectRideScreen") as! RWGPSSelectRideVC
                        self.present(vc, animated: true)
                    }
                }
            }
        } else {
            let vc = UIStoryboard(name: "RWGPS", bundle: nil).instantiateViewController(withIdentifier: "RWGPSLoginScreen") as! RWGPSLoginVC
            self.present(vc, animated: true)
        }
    }
}
//MARK: Save Ride
extension GroupRideSettingsVC {
    func setupSaveButton() {
        var previousSavedRides: [Ride] = []
        do {
            previousSavedRides = try UserDefaults.standard.get(objectType: [Ride].self, forKey: "saved_rides") ?? []
        } catch {
            return
        }
        
        if previousSavedRides.containsRide(ride) {
            saveButton.image = UIImage(systemName: "archivebox.fill")
            //saveButton.setImage(UIImage(systemName: "archivebox.fill"), for: .normal)
        } else {
            saveButton.image = UIImage(systemName: "archivebox")
        }
//        guard !previousSavedRides.containsRide(ride) else {
//            self.showFailureToast(message: "Ride is already saved.")
//            return
//        }
    }
    
    @IBAction func saveThisRide(_ sender: Any) {
        var previousSavedRides: [Ride] = []
        do {
            previousSavedRides = try UserDefaults.standard.get(objectType: [Ride].self, forKey: "saved_rides") ?? []
        } catch {
            self.showFailureToast(message: "Error saving ride")
            saveButton.image = UIImage(systemName: "archivebox")
            return
        }
        
        guard !previousSavedRides.containsRide(ride) else {
            self.showSuccessToast(message: "Ride has been unsaved!")
            previousSavedRides.removeAll { r in
                return r.id == ride.id
            }
            try? UserDefaults.standard.set(object: previousSavedRides, forKey: "saved_rides")
            saveButton.image = UIImage(systemName: "archivebox")
            return
        }
        
        previousSavedRides.append(ride)
        self.showSuccessToast(message: "Ride is saved!")
        saveButton.image = UIImage(systemName: "archivebox.fill")
        try? UserDefaults.standard.set(object: previousSavedRides, forKey: "saved_rides")
        print(previousSavedRides)
        
        
        
    }
}
