//
//  GroupUserLocationVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 9/2/21.
//

import UIKit

class GroupUserLocationVC: UIViewController {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var profileNameView: UILabel!
    @IBOutlet weak var profilePhoneView: UILabel!
    var user: GroupUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6.withAlphaComponent(0.9)
        //Profile View
        profileView.layer.cornerRadius = 10
        profileView.layer.borderWidth = 1
        profileView.layer.borderColor = UIColor.label.cgColor
        profileView.backgroundColor = .clear
        
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.width / 2
        profilePictureView.layer.borderWidth = 1
        profilePictureView.layer.borderColor = UIColor.label.cgColor
        
        profilePictureView.image = user.profilePicture?.toImage()
        profileNameView.text = user.displayName
        profilePhoneView.text = user.phoneNumber
    }
    
    @IBAction func callUserButtonClicked(_ sender: Any) {
        if let url = URL(string: "tel://\(user.phoneNumber.toLegalPhoneNumber())"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func callSOSButtonClicked(_ sender: Any) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let bikingVCBackdrop = (navigationController?.viewControllers[0] as? BottomSheetInfoGroupVC)?.backdropView as? BikingGroupVC {
            (bikingVCBackdrop.map.view(for: bikingVCBackdrop.map.annotations.getGroupUserAnnotation(for: user.email)!) as! GroupUserAnnotationView).inSelectedState = false
            bikingVCBackdrop.makeMapAnnotation(.smaller, for: user)
        }
    }
    
}

extension String {
    func toLegalPhoneNumber() -> String {
        let legalChars : Set<Character> =
               Set("1234567890")
           return String(self.filter {legalChars.contains($0) })
    }
}

enum AnnotationChangeType {
    case bigger
    case smaller
}
