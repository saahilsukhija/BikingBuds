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
        tableView.reloadData()
    }
}

extension BottomSheetInfoGroupVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupUserCell") as! GroupUserTableViewCell
        
        cell.setProperties(from: groupUsers[indexPath.row])
        cell.contentView.backgroundColor = .clear
        //Separator Full Line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //make groupUserAnnotation bigger or smaller, depending on if it's already selected
        if let bikingGroupVCBackdrop = backdropView as? BikingGroupVC {
            
            let groupUserAnnotation = bikingGroupVCBackdrop.map.annotations.getGroupUserAnnotation(for: groupUsers[indexPath.row].email)!
            //if annotationIsNOTSelected
            if  bikingGroupVCBackdrop.map.selectedAnnotations.getGroupUserAnnotation(for: groupUsers[indexPath.row].email) == nil {
                (bikingGroupVCBackdrop.map.view(for: groupUserAnnotation) as! GroupUserAnnotationView).inSelectedState = true
                bikingGroupVCBackdrop.map.selectAnnotation(groupUserAnnotation, animated: true)
            }
            
            let groupUserVC = storyboard?.instantiateViewController(identifier: "groupUserLocationScreen") as! GroupUserLocationVC
            groupUserVC.user = groupUsers[indexPath.row]
            navigationController?.pushViewController(groupUserVC, animated: true)
            
            //Center map to their location
            if let selectedUserLocation = Locations.locations[groupUsers[indexPath.row]] {
                backdropView.map.centerCameraTo(location: selectedUserLocation)
            }
            
            bikingGroupVCBackdrop.makeMapAnnotation(.bigger, for: groupUsers[indexPath.row])
            
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
