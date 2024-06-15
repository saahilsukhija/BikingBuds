//
//  NotificationTableViewCell.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 10/16/21.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    static let identifier = "notificationCell"
    @IBOutlet weak var titleView: UILabel!
    var type: AppNotification.NotificationType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with notification: AppNotification) {
        titleView.text = notification.title
        self.type = notification.type
        
        if notification.isRead {
            titleView.textColor = .systemGray4
        } else {
            titleView.textColor = .label
        }
    }
}
