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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var versionNumberLabel: UILabel!
    
    var settings = ["Low Power Mode", "Rider Icons", "Map Type", "Ride with GPS"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ride = try? UserDefaults.standard.get(objectType: Ride.self, forKey: "ride_temp") ?? Ride(id: UserDefaults.standard.string(forKey: "recent_group") ?? "000000", name: "(error)")
        setupSaveButton()
        setupRWGPSView()
        setupVersionLabel()
        
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(rwgpsRouteSelected), name: .rwgpsRouteLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rwgpsUserLogin), name: .rwgpsUserLogin, object: nil)
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func rwgpsRouteSelected() {
        self.tableView.reloadData()
        self.dismiss(animated: true)
    }
    
    @objc func rwgpsUserLogin() {
        self.tableView.reloadData()
    }
    func setupVersionLabel() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionNumberLabel.text = "version \(appVersion ?? "(error)")"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("settings view appeared")
        tableView.reloadData()
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

extension GroupRideSettingsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupRideSettingsCell.identifier) as! GroupRideSettingsCell
        if indexPath.row == 0 {
            cell.setup(title: settings[indexPath.row], status: UserSettings.shared.lowPowerModeEnabled ? "Enabled" : "Disabled")
        }
        else if indexPath.row == 1{
            cell.setup(title: settings[indexPath.row], status: UserSettings.shared.showInitialsOnMap ? "Initials" : "Pictures")
        }
        else if indexPath.row == 2 {
            let type = UserSettings.shared.mapType
            cell.setup(title: settings[indexPath.row], status: type == .hybrid ? "Hybrid" : (type == .standard ? "Standard" : "Satellite"))
        }
        else if indexPath.row == 3 {
            cell.setup(title: settings[indexPath.row], status: RWGPSUser.hasEmailAndPasswordStored() ? (RWGPSRoute.connected ? "Connected" : "Not Connected") : "Log In" )
        }
        //Separator Full Line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: LowPowerModeVC.identifier) as! LowPowerModeVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 1{
            let vc = storyboard?.instantiateViewController(withIdentifier: MapIconSelectVC.identifier) as! MapIconSelectVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 2{
            let vc = storyboard?.instantiateViewController(withIdentifier: MapTypeSelectVC.identifier) as! MapTypeSelectVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 3 {
            rwgpsViewTapped()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
//MARK: RWGPS:
extension GroupRideSettingsVC {
    func setupRWGPSView() {
//        connectWithRWGPSView.isUserInteractionEnabled = true
//        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rwgpsViewTapped))
//        connectWithRWGPSView.addGestureRecognizer(gestureRecognizer)
//        
//        connectWithRWGPSView.layer.cornerRadius = 10
//        connectWithRWGPSView.layer.borderColor = UIColor.black.cgColor
//        connectWithRWGPSView.layer.borderWidth = 1.5
//        
//        if RWGPSRoute.connected == true {
//            rwgpsConnectLabel.text = "Change the RideWithGPS Route"
//        } else {
//            rwgpsConnectLabel.text = "Connect With RideWithGPS"
//        }
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
            saveButton.image = UIImage(systemName: "bookmark.fill")
            //saveButton.setImage(UIImage(systemName: "archivebox.fill"), for: .normal)
        } else {
            saveButton.image = UIImage(systemName: "bookmark")
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
            saveButton.image = UIImage(systemName: "bookmark")
            return
        }
        
        previousSavedRides.append(ride)
        self.showSuccessToast(message: "Ride is saved!")
        saveButton.image = UIImage(systemName: "bookmark.fill")
        try? UserDefaults.standard.set(object: previousSavedRides, forKey: "saved_rides")
        print(previousSavedRides)
        
        
        
    }
}
