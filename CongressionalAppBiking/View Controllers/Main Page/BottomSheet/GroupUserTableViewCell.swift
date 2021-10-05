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
        
        var howLongAgoLastUpdated: String?
        if lastUpdated != "N/A" {
            var dateComponents = DateComponents()
            let splitStrings = lastUpdated.split(separator: ":")
            dateComponents.year = Calendar.current.component(.year, from: Date())
            dateComponents.month = Calendar.current.component(.month, from: Date())
            dateComponents.day = Calendar.current.component(.day, from: Date())
            dateComponents.hour = Int(String(splitStrings[0]))
            //print(Int(String(splitStrings[0])))
            dateComponents.minute = Int(String(splitStrings[1]))
            dateComponents.second = Calendar.current.component(.second, from: Date())

            //let userCalendar = Calendar(identifier: .gregorian)
            //let date = userCalendar.date(from: dateComponents)
            howLongAgoLastUpdated = lastUpdated//date?.timeAgoSinceDate() ?? "N/A"
        }
        lastUpdatedAt.text = "Last Updated: \(howLongAgoLastUpdated ?? "N/A")"
        profileImage.image = groupUser.profilePicture?.toImage()
        
        backgroundColor = .clear
    }

}
