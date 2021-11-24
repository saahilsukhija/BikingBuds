//
//  SavedRideCell.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 11/20/21.
//

import UIKit

class SavedRideCell: UITableViewCell {

    static let identifier = "savedRideCell"
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var code: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp(name: String, code: String) {
        self.name.text = name
        self.code.text = code
    }

}
