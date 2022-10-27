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
        
        tableView.estimatedRowHeight = 75
        tableView.tableFooterView = UIView()
        
        view.backgroundColor = .systemGray6.withAlphaComponent(0.9)
        tableView.backgroundColor = .clear
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationsUpdated), name: .newAnnouncement, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationsUpdated), name: .groupUsersUpdated, object: nil)
    
    }
    
    @objc func notificationsUpdated() {
        self.tableView.reloadData()
    }
    
    @IBAction func closeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NotificationsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        backgroundView.backgroundColor = .systemGray5.withAlphaComponent(0.9)
        
        let sectionLabel = UILabel(frame: CGRect(x: 5, y: 5, width: tableView.frame.size.width, height: 20))
        sectionLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        sectionLabel.textColor = .label
        
        if section == 0 {
            sectionLabel.text = "Announcements"
        } else {
            sectionLabel.text = "Ride Updates"
        }
        backgroundView.addSubview(sectionLabel)
        
        return backgroundView
    }
    
    func requiredHeight(text:String, size: CGFloat, fontName: String) -> CGFloat {
        return text.height(withConstrainedWidth: view.frame.size.width-20, font: UIFont(name: fontName, size: size)!)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) {
            let notification = Locations.announcementNotifications[indexPath.row]
            let title = "\(Locations.groupUsers.groupUserFrom(email: notification.email)?.displayName ?? notification.email ?? "someone"):"
            let message = "\"\(notification.title ?? "unable to get message")\""
            
            let required = requiredHeight(text: title, size: 18, fontName: "Poppins-Medium") + requiredHeight(text: message, size: 16, fontName: "Poppins-Light")
            return required > 75 ? required+20 : 75
        }
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return Locations.announcementNotifications.count
        }
        return Locations.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AnnouncementTableViewCell.identifier) as! AnnouncementTableViewCell
            let notification = Locations.announcementNotifications[indexPath.row]
        
            cell.configure(with: notification)
        
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier) as! NotificationTableViewCell
            let notification = Locations.notifications[indexPath.row]
        
            cell.configure(with: notification)
        
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(indexPath.section == 0) {
        }

        
    }
    
}
