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
                print("\(user.displayName!) is a rider")
                riders.append(user)
            } else {
                print("\(user.displayName!) is a non rider")
                nonRiders.append(user)
            }
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Riders"
        }
        return "Non Riders"
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
        
        if indexPath.section == 0 {
            selectedRider(at: indexPath)
        } else if indexPath.section == 1 {
            selectedNonRider(at: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func selectedRider(at indexPath: IndexPath) {
        //make groupUserAnnotation bigger or smaller, depending on if it's already selected
        print(indexPath.row)
        guard let bikingGroupVCBackdrop = backdropView as? BikingGroupVC else { return }
        
        guard let groupUserAnnotation = bikingGroupVCBackdrop.map.annotations.getGroupUserAnnotation(for: riders[indexPath.row].email) else { return }
        
        //if annotationIsNOTSelected
        if  bikingGroupVCBackdrop.map.selectedAnnotations.getGroupUserAnnotation(for: riders[indexPath.row].email) == nil {
            (bikingGroupVCBackdrop.map.view(for: groupUserAnnotation) as? GroupUserAnnotationView)?.inSelectedState = true
            bikingGroupVCBackdrop.map.selectAnnotation(groupUserAnnotation, animated: true)
        }
        
        let groupUserVC = storyboard?.instantiateViewController(identifier: "groupUserLocationScreen") as! GroupUserLocationVC
        groupUserVC.user = riders[indexPath.row]
        groupUserVC.isCurrentUser = (indexPath.row == 0)
        groupUserVC.groupID = bikingGroupVCBackdrop.groupID
        groupUserVC.riderType = Locations.riderTypes[riders[indexPath.row]]
        navigationController?.pushViewController(groupUserVC, animated: true)
        
        //Center map to their location
        if let selectedUserLocation = Locations.locations[riders[indexPath.row]] {
            backdropView.map.centerCameraTo(location: selectedUserLocation, regionRadius: backdropView.map.currentRadius())
        }
        
        bikingGroupVCBackdrop.makeMapAnnotation(.bigger, for: riders[indexPath.row])
        
    }
    
    func selectedNonRider(at indexPath: IndexPath) {
        
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
        searchBar.placeholder = "Enter rider's name... (Does Not Work)"
        
        navigationItem.titleView = searchBar
    }
}
