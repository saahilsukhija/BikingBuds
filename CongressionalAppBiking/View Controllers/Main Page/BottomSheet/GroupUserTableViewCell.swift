//
//  GroupUserTableViewCell.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/26/21.
//

import UIKit

class GroupUserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var lastUpdatedAt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.label.cgColor
        
    }
    
    func setProperties(from groupUser: GroupUser, lastUpdated: String, isCurrentUser: Bool) {
        if isCurrentUser {
            profileName.text = groupUser.displayName + " (You)"
        } else {
            profileName.text = groupUser.displayName
        }
        
        lastUpdatedAt.text = "\(lastUpdated)"
        if !(lastUpdated == "" || lastUpdated == "Now") {
            lastUpdatedAt.text = "\(lastUpdated) ago"
        }
        profileImage.image = groupUser.profilePicture?.toImage()
        
        backgroundColor = .clear
    }

}
