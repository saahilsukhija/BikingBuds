//
//  GroupUserLocationVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 9/2/21.
//

import UIKit
import MapKit

class GroupUserLocationVC: UIViewController {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var profileNameView: UILabel!
    @IBOutlet weak var profilePhoneView: UILabel!
    
    @IBOutlet weak var callPhoneButton: UIButton!
    @IBOutlet weak var callSOSButton: UIButton!
    
    @IBOutlet weak var changeGroupUserSettingsView: UIView!
    @IBOutlet weak var changeRiderTypeButton: UIButton!
    @IBOutlet weak var directionsToButton: UIButton!
    
    var isCurrentUser = false
    var riderType: RiderType!
    var user: GroupUser!
    var groupID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6.withAlphaComponent(0.9)
        //Profile View
        profileView.layer.cornerRadius = 10
        //profileView.layer.borderWidth = 1
        //profileView.layer.borderColor = UIColor.label.cgColor
        //profileView.backgroundColor = .clear
        profileView.dropShadow()
        
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.width / 2
        profilePictureView.layer.borderWidth = 1
        profilePictureView.layer.borderColor = UIColor.label.cgColor
        
        directionsToButton.layer.cornerRadius = 10
        profilePictureView.image = user.profilePicture?.toImage()
        profileNameView.text = user.displayName
        profilePhoneView.text = user.phoneNumber
        
        callPhoneButton.dropShadow()
        callPhoneButton.layer.borderColor = UIColor.accentColorDark.cgColor
        callPhoneButton.layer.borderWidth = 1
        
        callSOSButton.dropShadow()
        callSOSButton.layer.borderColor = UIColor.systemRed.cgColor
        callSOSButton.layer.borderWidth = 1
        
        directionsToButton.dropShadow()
        directionsToButton.layer.borderColor = UIColor.black.cgColor
        directionsToButton.layer.borderWidth = 1
    }
    
    @IBAction func callUserButtonClicked(_ sender: Any) {
        if let url = URL(string: "tel://\(user.phoneNumber.toLegalPhoneNumber())"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func callSOSButtonClicked(_ sender: Any) {
        if let emergencyPhoneNumber = user.emergencyPhoneNumber {
            if let url = URL(string: "tel://\(emergencyPhoneNumber.toLegalPhoneNumber())"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        else {
            if let url = URL(string: "tel://911"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func changeRiderTypeButtonClicked(_ sender: Any) {
        let changeChoices = UIAlertController(title: "Change Ride Type", message: "Join as a specific role. Defaulted to Rider", preferredStyle: .actionSheet)
        changeChoices.view.tintColor = .accentColor
        
        changeChoices.addAction(UIAlertAction(title: "Rider", style: .default, handler: { [self] _ in
            riderType = .rider
            updateChangeRiderTypeButton(with: "You are currently a rider. Change.")
            NotificationCenter.default.post(name: .userIsRider, object: nil)
        }))
        changeChoices.addAction(UIAlertAction(title: "Non-Rider / Spectator", style: .default, handler: { [self] _ in
            riderType = .spectator
            updateChangeRiderTypeButton(with: "You are currently a non-rider. Change.")
            NotificationCenter.default.post(name: .userIsNonRider, object: nil)
        }))
        
        
        changeChoices.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(changeChoices, animated: true, completion: nil)
    }
    
    func updateChangeRiderTypeButton(with string: String, uploadRiderType: Bool = true) {
        let mutableTitle = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font : UIFont(name: "Montserrat-SemiBold", size: 16)!])
        mutableTitle.setColor(color: .accentColor, forText: "Change.")
        changeRiderTypeButton.setAttributedTitle(mutableTitle, for: .normal)
        
        if uploadRiderType {
            Authentication.riderType = riderType
            UserLocationsUpload.uploadUserRideType(riderType, group: groupID)
        }
        
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
            directionsToButton.isHidden = true
            changeGroupUserSettingsView.isHidden = false
        } else {
            callSOSButton.isHidden = false
            callPhoneButton.isHidden = false
            directionsToButton.isHidden = false
            changeGroupUserSettingsView.isHidden = true
        }
        
        if Locations.riderTypes[user] == .spectator {
            directionsToButton.isHidden = true
        }
        
        updateChangeRiderTypeButton(with: "You are currently a \(HelperFunctions.makeLegalRiderType(riderType)). Change.", uploadRiderType: false)
        if let first = user.displayName.components(separatedBy: " ").first {
            let mutableTitle = NSAttributedString(string: "Directions to \(first)", attributes: [NSAttributedString.Key.font : UIFont(name: "Montserrat-SemiBold", size: 20) ?? .systemFont(ofSize: 20)])
            directionsToButton.setAttributedTitle(mutableTitle, for: .normal)
        } else {
            let mutableTitle = NSAttributedString(string: "Directions", attributes: [NSAttributedString.Key.font : UIFont(name: "Montserrat-SemiBold", size: 20) ?? .systemFont(ofSize: 20)])
            directionsToButton.setAttributedTitle(mutableTitle, for: .normal)
        }
       
    }
    
    @IBAction func goToMap(_ sender: Any) {
        guard let userLatitude = Locations.locations[user]?.latitude, let userLongitude = Locations.locations[user]?.longitude else {
            showFailureToast(message: "Error getting user location")
            return
        }

//        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: selfLatitude, longitude: selfLongitude)))
//        source.name = "Source"
//
//        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)))
//        destination.name = "Destination"
//
//        MKMapItem.openMaps(
//          with: [source, destination],
//          launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
//        )
        
        let coordinate = CLLocationCoordinate2DMake(userLatitude, userLongitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = "Target location"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
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
