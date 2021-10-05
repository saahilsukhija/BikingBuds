//
//  BikingVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/9/21.
//

import UIKit
import CoreLocation
import MapKit

class BikingGroupVC: BikingVCs {
    
    @IBOutlet weak var mapView: MKMapView!
    var groupID: String!
    var groupName: String!
    var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingView)
        
        super.setUp(map: mapView)
        self.addGroupCodeToNavController()
        
        mapView.delegate = self
        mapView.register(GroupUserAnnotationView.self, forAnnotationViewWithReuseIdentifier: "groupUser")
        mapView.showsUserLocation = false
        
        navigationController?.navigationItem.title = groupName
        navigationController?.title = groupName
        
        Locations.resetGroupUsers(for: groupID)
        Locations.addNotifications(for: groupID)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .locationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .groupUsersUpdated, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(userIsRider), name: .userIsRider, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userIsNonRider), name: .userIsNonRider, object: nil)
        loadingView.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Locations.removeNotifications(for: groupID)
    }
    func addGroupCodeToNavController() {
        let groupCodeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width / 2, height: navigationController?.navigationBar.frame.size.height ?? 75))
        groupCodeLabel.font = UIFont(name: "Singhala Simhan MN", size: 16)
        groupCodeLabel.text = groupName
        groupCodeLabel.textColor = .black
        groupCodeLabel.textAlignment = .center
        
        groupCodeLabel.layer.cornerRadius = groupCodeLabel.frame.size.height / 2
        groupCodeLabel.dropShadow()
        //groupCodeLabel.layer.borderWidth = 1
        //groupCodeLabel.layer.borderColor = UIColor.black.cgColor
        
        groupCodeLabel.layer.backgroundColor = UIColor.white.cgColor
        
        navigationItem.titleView = groupCodeLabel
        
        configureInvitePeopleButton()
        configureLeaveGroupButton()
    }
    
    func configureInvitePeopleButton() {
        let invitePeopleButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        invitePeopleButton.setImage(UIImage(systemName: "plus"), for: .normal)
        invitePeopleButton.setTitle("Invite People", for: .normal)
        invitePeopleButton.setTitleColor(.accentColor, for: .normal)
        
        invitePeopleButton.backgroundColor = preferredBackgroundColor
        invitePeopleButton.tintColor = .accentColor
        invitePeopleButton.dropShadow()
        invitePeopleButton.addTarget(self, action: #selector(openInvitePeopleScreen), for: .touchUpInside)
        invitePeopleButton.layer.cornerRadius = invitePeopleButton.frame.size.height / 2
        invitePeopleButton.layer.borderWidth = 1
        invitePeopleButton.layer.borderColor = UIColor.label.cgColor
        invitePeopleButton.layer.masksToBounds = true
        
        //Make invitePeople track the bottom
        bottomSheet.view.addSubview(invitePeopleButton)
        invitePeopleButton.isUserInteractionEnabled = true
        invitePeopleButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            invitePeopleButton.bottomAnchor.constraint(equalTo: bottomSheet.surfaceView.topAnchor,
                                                       constant: -5),
            invitePeopleButton.leftAnchor.constraint(equalTo: bottomSheet.surfaceView.leftAnchor, constant: 5),
            invitePeopleButton.widthAnchor.constraint(equalTo: bottomSheet.surfaceView.widthAnchor, constant: -view.frame.size.width / 2 - 10),
            invitePeopleButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    func configureLeaveGroupButton() {
        let leaveGroupButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        leaveGroupButton.setImage(UIImage(systemName: "figure.wave"), for: .normal)
        leaveGroupButton.setTitle("Leave Group", for: .normal)
        leaveGroupButton.setTitleColor(.systemRed, for: .normal)

        leaveGroupButton.backgroundColor = preferredBackgroundColor
        leaveGroupButton.tintColor = .systemRed
        leaveGroupButton.dropShadow()
        leaveGroupButton.addTarget(self, action: #selector(endRide), for: .touchUpInside)
        leaveGroupButton.layer.cornerRadius = leaveGroupButton.frame.size.height / 2
        leaveGroupButton.layer.borderWidth = 1
        leaveGroupButton.layer.borderColor = UIColor.label.cgColor
        leaveGroupButton.layer.masksToBounds = true
        
        //Make invitePeople track the bottom
        bottomSheet.view.addSubview(leaveGroupButton)
        leaveGroupButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            leaveGroupButton.bottomAnchor.constraint(equalTo: bottomSheet.surfaceView.topAnchor,
                                                       constant: -5),
            leaveGroupButton.rightAnchor.constraint(equalTo: bottomSheet.surfaceView.rightAnchor, constant: -5),
            leaveGroupButton.widthAnchor.constraint(equalTo: bottomSheet.surfaceView.widthAnchor, constant: -view.frame.size.width / 2 - 10),
            leaveGroupButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    @objc func openInvitePeopleScreen() {
        let vc = storyboard?.instantiateViewController(identifier: "shareCodeScreen") as! ShareInviteCodeVC
        vc.group = groupID
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func userLocationsUpdated() {
        ((bottomSheet.contentViewController as? UINavigationController)?.viewControllers[0] as? BottomSheetInfoGroupVC)?.reloadGroupUsers()
        mapView.drawAllGroupMembers(includingSelf: true)
    }
    
    @objc func userIsNonRider() {
        previousLatitude = 0
        previousLongitude = 0
        locationManager.stopUpdatingLocation()
    }
    
    @objc func userIsRider() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0].coordinate.roundTo(places: Preferences.coordinateRoundTo)
        let (latitude, longitude) = (location.latitude, location.longitude)
        
        if previousLatitude != latitude || previousLongitude != longitude {
            uploadUserLocation(location)
        } else {
            //Same Location, not uploading to cloud
        }
        
        super.updatePreviousLocations(location)
    }
    
    override func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        super.locationManagerDidChangeAuthorization(manager)
        
        if let location = manager.location?.coordinate {
            uploadUserLocation(location)
            
        }
    }
    
    func uploadUserLocation(_ location: CLLocationCoordinate2D) {
        if Authentication.riderType == .rider {
            UserLocationsUpload.uploadCurrentLocation(group: groupID, location: location) { completed, message in
                if !completed {
                    print(message!)
                }
            }
        }
    }
    
    
}

extension BikingGroupVC {

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        var annotationView: MKAnnotationView!
        var annotationIdentifier: String!
        
        if annotation.isKind(of: GroupUserAnnotation.self) {
            annotationIdentifier = "groupUser"
            annotationView = GroupUserAnnotationView(annotation: annotation as! GroupUserAnnotation, reuseIdentifier: annotationIdentifier)
            annotationView.frame = (annotationView as! GroupUserAnnotationView).containerView.frame
    
        } else {
            annotationIdentifier = "marker"
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("selectedAnnotation")
        guard let annotationView = view as? GroupUserAnnotationView else { return }
        guard let bottomSheetNav = (bottomSheet.contentViewController as? UINavigationController) else { return }
        guard let selectedEmail = (annotationView.annotation as? GroupUserAnnotation)?.email else { return }
        bottomSheetNav.popToRootViewController(animated: true)
        (bottomSheetNav.viewControllers[0] as! BottomSheetInfoGroupVC).mapSelectedPerson(selectedEmail)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("deselectedAnnotation")
        (bottomSheet.contentViewController as? UINavigationController)?.popToRootViewController(animated: true)
    }
    
    func makeMapAnnotation(_ annotationChangeType: AnnotationChangeType, for groupUser: GroupUser) {
        guard let groupUserAnnotation = mapView.annotations.getGroupUserAnnotation(for: groupUser.email) else { return }
        
        guard let groupUserAnnotationView = mapView.view(for: groupUserAnnotation) as? GroupUserAnnotationView else { return }
    
        if annotationChangeType == .bigger {
            groupUserAnnotationView.makeAnnotationSelected()
        } else {
            groupUserAnnotationView.makeAnnotationDeselected()
        }
        
        mapView.drawGroupMember(email: groupUser.email, location: groupUserAnnotation.coordinate)
        
    }
}
