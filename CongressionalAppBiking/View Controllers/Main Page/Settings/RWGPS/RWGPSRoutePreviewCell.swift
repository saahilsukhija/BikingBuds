//
//  RWGPSRoutePreviewCell.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 12/2/22.
//

import UIKit

class RWGPSRoutePreviewCell: UITableViewCell {
    static let identifier = "RidePreview"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with ride: RWGPSRoutePreview) {
        nameLabel.text = ride.name
        
        if ride.description != "" {
            descriptionLabel.text = ride.description
        } else {
            descriptionLabel.text = "No description given"
            descriptionLabel.textColor = .systemGray
        }
        dateLabel.text = dateToString(ride.createdAt)
    }
    
    func dateToString(_ date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.month ?? 0)/\(components.day ?? 0)/\(components.year ?? 0)"
    }

}
