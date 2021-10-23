//
//  NotificationsVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 10/16/21.
//

import UIKit

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewedIndexPaths: [IndexPath]!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 75
        tableView.tableFooterView = UIView()
        
        view.backgroundColor = .systemGray6.withAlphaComponent(0.9)
        tableView.backgroundColor = .clear
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
    
    }
    
    @IBAction func closeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NotificationsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Locations.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier) as! NotificationTableViewCell
        let notification = Locations.notifications[indexPath.row]
        
        cell.configure(with: notification)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let bikingGroupVC = presentingViewController as? BikingGroupVC else { print("1"); return }
        guard let annotation = bikingGroupVC.mapView.annotations.getGroupUserAnnotation(for: Locations.notifications[indexPath.row].email) else {  print("2"); return }
        guard let annotationView = bikingGroupVC.mapView(bikingGroupVC.mapView, viewFor: annotation) else {  print("3"); return }
        
        bikingGroupVC.mapView(bikingGroupVC.mapView, didSelect: annotationView)

        
    }
    
}
