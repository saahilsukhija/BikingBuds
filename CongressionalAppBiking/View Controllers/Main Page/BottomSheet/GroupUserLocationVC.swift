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
    
    @IBOutlet weak var callPhoneButton: UIButton!
    @IBOutlet weak var callSOSButton: UIButton!
    
    @IBOutlet weak var changeGroupUserSettingsView: UIView!
    @IBOutlet weak var changeRiderTypeButton: UIButton!
    
    var isCurrentUser = false
    var riderType: RiderType!
    var user: GroupUser!
    var groupID: String!
    
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
    
    @IBAction func changeRiderTypeButtonClicked(_ sender: Any) {
        //guard let baseVC = (navigationController?.viewControllers[0] as? BottomSheetInfoGroupVC)?.backdropView else { return }
        let changeChoices = UIAlertController(title: "Change Ride Type", message: "Join as a specific role. Defaulted to Rider", preferredStyle: .actionSheet)
        
        changeChoices.addAction(UIAlertAction(title: "Rider", style: .default, handler: { [self] _ in
            riderType = .rider
            updateChangeRiderTypeButton(with: "You are currently a Rider. Change.")
        }))
        changeChoices.addAction(UIAlertAction(title: "Non-Rider / Spectator", style: .default, handler: { [self] _ in
            riderType = .spectator
            updateChangeRiderTypeButton(with: "You are currently a Non-Rider. Change.")
        }))
        changeChoices.addAction(UIAlertAction(title: "Not Riding This Time", style: .default, handler: { [self] _ in
            riderType = .notRidingCurrently
            updateChangeRiderTypeButton(with: "You are currently a 'Not Riding Now'. Change.")
        }))
        
        
        changeChoices.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(changeChoices, animated: true, completion: nil)
    }
    
    func updateChangeRiderTypeButton(with string: String) {
        let mutableTitle = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font : UIFont(name: "Sinhala Sangam MN", size: 20)!])
        mutableTitle.setColor(color: .accentColor, forText: "Change.")
        changeRiderTypeButton.setAttributedTitle(mutableTitle, for: .normal)
        
        Authentication.riderType = riderType
        UserLocationsUpload.uploadUserRideType(riderType, group: groupID)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let bikingVCBackdrop = (navigationController?.viewControllers[0] as? BottomSheetInfoGroupVC)?.backdropView as? BikingGroupVC {
            
            if let mapAnnotation = bikingVCBackdrop.map.annotations.getGroupUserAnnotation(for: user.email) {
                (bikingVCBackdrop.map.view(for: mapAnnotation) as? GroupUserAnnotationView)?.inSelectedState = false
            }
            bikingVCBackdrop.makeMapAnnotation(.smaller, for: user)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isCurrentUser {
            callSOSButton.isHidden = true
            callPhoneButton.isHidden = true
            
            changeGroupUserSettingsView.isHidden = false
        } else {
            callSOSButton.isHidden = false
            callPhoneButton.isHidden = false
            
            changeGroupUserSettingsView.isHidden = true
        }
        
        updateChangeRiderTypeButton(with: "You are currently a \(HelperFunctions.makeLegalRiderType(riderType)). Change.")
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
