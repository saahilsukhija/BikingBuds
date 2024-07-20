//
//  MapIconSelectVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/18/24.
//

import UIKit

class MapIconSelectVC: UIViewController {
    
    static let identifier = "MapIconSelectScreen"
    
    @IBOutlet weak var initialsView: UIView!
    @IBOutlet weak var picturesView: UIView!
    
    @IBOutlet weak var initialsCheckboxImageView: UIImageView!
    @IBOutlet weak var picturesCheckboxImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialsView.isUserInteractionEnabled = true
        picturesView.isUserInteractionEnabled = true
        
        initialsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(initialsViewClicked)))
        picturesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(picturesViewClicked)))
        
        if UserSettings.shared.showInitialsOnMap {
            initialsViewClicked()
        } else {
            picturesViewClicked()
        }
        
        initialsView.dropShadow()
        picturesView.dropShadow()
        
        //self.navigationController?.navigationBar.topItem?.title = "Choose Icon Type"
        navigationController?.navigationItem.title = "Choose Icon Type"
        self.title = "Choose Icon Type"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    @objc func initialsViewClicked() {
        initialsCheckboxImageView.image = UIImage(systemName: "checkmark.circle.fill")
        picturesCheckboxImageView.image = UIImage(systemName: "circle")
        UserSettings.shared.showInitials()
        NotificationCenter.default.post(name: .mapIconPreferenceChanged, object: nil)
        
    }
    
    @objc func picturesViewClicked() {
        picturesCheckboxImageView.image = UIImage(systemName: "checkmark.circle.fill")
        initialsCheckboxImageView.image = UIImage(systemName: "circle")
        UserSettings.shared.showInitials(false)
        NotificationCenter.default.post(name: .mapIconPreferenceChanged, object: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
