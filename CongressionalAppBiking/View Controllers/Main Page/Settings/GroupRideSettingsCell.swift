//
//  GroupRideSettingsCell.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/18/24.
//

import UIKit

class GroupRideSettingsCell: UITableViewCell {

    static let identifier = "GroupRideSettingsCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(title: String, status: String) {
        self.titleLabel.text = title
        self.statusLabel.text = status
        self.statusLabel.textColor = .systemGray
    }

}
