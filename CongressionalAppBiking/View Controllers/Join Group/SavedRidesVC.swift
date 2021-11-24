//
//  SavedRidesVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 11/12/21.
//

import UIKit

class SavedRidesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var savedRides: [Ride] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            savedRides = try UserDefaults.standard.get(objectType: [Ride].self, forKey: "saved_rides") ?? []
        } catch {
            showFailureToast(message: "Error getting saved rides")
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func closeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension SavedRidesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SavedRideCell.identifier) as! SavedRideCell
        cell.setUp(name: savedRides[indexPath.row].name, code: savedRides[indexPath.row].id)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRides.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (presentingViewController as? JoinGroupVC)?.savedRideChosen(savedRides[indexPath.row].id)
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
        
        self.showSuccessToast(message: "\(savedRides[indexPath.row].name ?? "(error)") selected")
    }
    
}
