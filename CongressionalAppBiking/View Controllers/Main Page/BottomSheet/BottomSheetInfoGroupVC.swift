//
//  BottomSheetInfoVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/23/21.
//

import UIKit
import CoreLocation
class BottomSheetInfoGroupVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var backdropView: BikingVCs!
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 20, width: view.frame.size.width, height: (navigationController?.navigationBar.frame.size.height)!))
    
    var groupUsers: [GroupUser] = []
    var riders: [GroupUser] = []
    var nonRiders: [GroupUser] = []
    
    var lastUploadedTimes: [GroupUser : String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 75
        tableView.tableFooterView = UIView()
        
        view.backgroundColor = .systemGray6.withAlphaComponent(0.9)
        tableView.backgroundColor = .clear
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        backdropView.bottomSheet.track(scrollView: self.tableView)
        self.setUpNavigationBar()
        self.hideKeyboardWhenTappedAround()
    }
    
    func reloadGroupUsers() {
        groupUsers = Locations.groupUsers
        lastUploadedTimes = Locations.lastUpdated
        
        bringCurrentUserToFront()
        filterRidersAndNonRiders()
        
        tableView.reloadData()
    }
    
    func bringCurrentUserToFront() {
        guard let email = Authentication.user?.email else { return }
        guard let groupUser = groupUsers.groupUserFrom(email: email) else { return }
        guard let indexOfGroupUser = groupUsers.firstIndex(of: groupUser) else { return }
        
        groupUsers.swapAt(0, indexOfGroupUser)
        
    }
    
    func filterRidersAndNonRiders() {
        riders.removeAll()
        nonRiders.removeAll()
        
        for user in groupUsers {
            if Locations.riderTypes[user] == .rider {
                riders.append(user)
            } else {
                nonRiders.append(user)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let bikingGroupBackdrop = backdropView as? BikingGroupVC {
            bikingGroupBackdrop.mapView.selectedAnnotations.forEach({ annotation in
                bikingGroupBackdrop.mapView.deselectAnnotation(annotation, animated: true)
            })
        }
    }
}

extension BottomSheetInfoGroupVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return riders.count
        }
        return nonRiders.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        backgroundView.backgroundColor = .systemGray5.withAlphaComponent(0.9)
        
        let sectionLabel = UILabel(frame: CGRect(x: 5, y: 5, width: tableView.frame.size.width, height: 20))
        sectionLabel.font = UIFont(name: "DIN Alternate Bold", size: 20)
        sectionLabel.textColor = .label
        
        if section == 0 {
            sectionLabel.text = "Riders"
        } else {
            sectionLabel.text = "Non Riders"
        }
        backgroundView.addSubview(sectionLabel)
        
        return backgroundView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupUserCell") as! GroupUserTableViewCell
        let dataSet = indexPath.section == 0 ? riders : nonRiders
        
        let groupUser = dataSet[indexPath.row]
        let isCurrentUser = groupUser.email == Authentication.user?.email
        
        cell.setProperties(from: groupUser, lastUpdated: lastUploadedTimes[groupUser] ?? "N/A", isCurrentUser: isCurrentUser)
        cell.contentView.backgroundColor = .clear
        //Separator Full Line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPerson(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func selectedPerson(at indexPath: IndexPath) {
        guard let bikingGroupVCBackdrop = backdropView as? BikingGroupVC else { return }
        
        let dataSet = indexPath.section == 0 ? riders : nonRiders
        
        if indexPath.section == 0 {
            guard let groupUserAnnotation = bikingGroupVCBackdrop.map.annotations.getGroupUserAnnotation(for: dataSet[indexPath.row].email) else { return }
            (bikingGroupVCBackdrop.map.view(for: groupUserAnnotation) as? GroupUserAnnotationView)?.inSelectedState = true
            
            //Center map to their location
            if let selectedUserLocation = Locations.locations[dataSet[indexPath.row]] {
                backdropView.map.centerCameraTo(location: selectedUserLocation, regionRadius: backdropView.map.currentRadius())
            }
            
            bikingGroupVCBackdrop.makeMapAnnotation(.bigger, for: dataSet[indexPath.row])
        }
        
        
        let groupUserVC = storyboard?.instantiateViewController(identifier: "groupUserLocationScreen") as! GroupUserLocationVC
        groupUserVC.user = dataSet[indexPath.row]
        groupUserVC.isCurrentUser = (Authentication.user?.email ?? "" == dataSet[indexPath.row].email)
        groupUserVC.groupID = bikingGroupVCBackdrop.groupID
        groupUserVC.riderType = Locations.riderTypes[dataSet[indexPath.row]]
        navigationController?.pushViewController(groupUserVC, animated: true)
        
    }
    
    func mapSelectedPerson(_ email: String) {
        let dataSet = riders.groupUserFrom(email: email) != nil ? riders : nonRiders
        for (index, user) in dataSet.enumerated() {
            if user.email == email {
                tableView(tableView, didSelectRowAt: IndexPath(row: index, section: dataSet.groupUserFrom(email: email) != nil ? 0 : 1))
            }
        }
    }
    
}

extension BottomSheetInfoGroupVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        NotificationCenter.default.post(name: .searchBarClicked, object: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
}

//MARK: Initial Setup
extension BottomSheetInfoGroupVC {
    func setUpNavigationBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Enter rider's name..."
        
        navigationItem.titleView = searchBar
    }
}
