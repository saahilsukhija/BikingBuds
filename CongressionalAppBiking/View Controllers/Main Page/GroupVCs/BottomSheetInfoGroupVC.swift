//
//  BottomSheetInfoVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/23/21.
//

import UIKit

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

        let groupUserVC = storyboard?.instantiateViewController(identifier: "groupUserLocationScreen") as! GroupUserLocationVC
        groupUserVC.user = groupUsers[indexPath.row]
        navigationController?.pushViewController(groupUserVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension BottomSheetInfoGroupVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        NotificationCenter.default.post(name: .searchBarClicked, object: nil)
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
