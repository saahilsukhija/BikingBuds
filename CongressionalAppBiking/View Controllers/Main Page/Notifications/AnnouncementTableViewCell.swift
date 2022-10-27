//
//  AnnouncementTableViewCell.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 6/23/22.
//

import UIKit

class AnnouncementTableViewCell: UITableViewCell {

    static let identifier = "announcementCell"
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var subtitleView: UILabel!
    @IBOutlet weak var timeView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with notification: AnnouncementNotification) {
        titleView.text = "\(Locations.groupUsers.groupUserFrom(email: notification.email)?.displayName ?? notification.email ?? "someone"):"
        subtitleView.text = "\"\(notification.title ?? "unable to get message")\""
        
        timeView.text = notification.time.timeAgo()
        
        if notification.isRead {
            titleView.textColor = .systemGray4
        } else {
            titleView.textColor = .label
        }
    }

}
