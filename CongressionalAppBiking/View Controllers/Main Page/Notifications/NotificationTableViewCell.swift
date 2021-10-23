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
    @IBOutlet weak var subtitleView: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
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
        subtitleView.text = notification.subTitle
        self.type = notification.type
        
        var image = UIImage(systemName: "bicycle")
        switch type {
            
        case .fall:
            image = UIImage(systemName: "cross.case.fill")
            typeImage.tintColor = .systemRed
        case .distanceTooFar:
            image = UIImage(systemName: "figure.stand.line.dotted.figure.stand")
            typeImage.tintColor = .systemOrange
        case .userJoined:
            image = UIImage(systemName: "figure.walk")
            typeImage.tintColor = .systemGreen
        case .userLeft:
            image = UIImage(systemName: "figure.wave")
            typeImage.tintColor = .systemYellow
        default:
            image = UIImage(systemName: "bicycle")
        }
        
        typeImage.image = image
        
        if notification.isRead {
            titleView.textColor = .systemGray4
        } else {
            titleView.textColor = .label
        }
    }
}
