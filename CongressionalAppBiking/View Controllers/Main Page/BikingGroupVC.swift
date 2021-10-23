//
//  BikingVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/9/21.
//

import UIKit
import CoreLocation
import MapKit
import CoreMotion
class BikingGroupVC: BikingVCs {
    
    @IBOutlet weak var mapView: MKMapView!
    var groupID: String!
    var groupName: String!
    var loadingView: UIView!
    
    var fallTimer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingView)
        
        super.setUp(map: mapView)
        self.addGroupCodeToNavController()
        self.setUpMotionManager()
        
        mapView.delegate = self
        mapView.register(GroupUserAnnotationView.self, forAnnotationViewWithReuseIdentifier: "groupUser")
        mapView.showsUserLocation = false
        
        navigationController?.navigationItem.title = groupName
        navigationController?.title = groupName
        
        Locations.resetGroupUsers(for: groupID)
        Locations.addNotifications(for: groupID)
        Locations.addNotificationsForFallDetection(for: groupID)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .locationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .groupUsersUpdated, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(userIsRider), name: .userIsRider, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userIsNonRider), name: .userIsNonRider, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(otherUserHasFallen), name: .userHasFallen, object: nil)
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
        
        updateNotificationCount()
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
    
    @objc func otherUserHasFallen() {
        let email = Locations.recentFall.keys.first ?? "none"
        showAnimationNotification(animationName: "Caution", message: "\(Locations.groupUsers.groupUserFrom(email: email)?.displayName ?? email) has fallen.", color: .systemOrange, fontColor: .systemOrange)
        updateNotificationCount()
    }
    
    func updateNotificationCount() {
        notificationCountLabel.text = "\(Locations.notifications.count)"
    }
}


//MARK: Accelerometer Updates
extension BikingGroupVC {
    func setUpMotionManager() {
        movementManager = CMMotionManager()
        movementManager.accelerometerUpdateInterval = 0.1
        movementManager.startAccelerometerUpdates(to: .main) { data, error in
            if let error = error {
                print("error with accelerometer: \(error.localizedDescription)")
            }
            
            let acceleration = abs(data!.acceleration.z)

            if acceleration > 1.5 {
                self.consecutiveAccelerationRedFlags += 1
                print("red flag")
            } else {
                self.consecutiveAccelerationRedFlags = 0
            }
            
            if self.consecutiveAccelerationRedFlags >= 2 {
                print("proper fall")
                
                self.userDidFall()
            }
        }
    }
    
    func configureFallScreen() {
        let guide = view.safeAreaLayoutGuide
        let frame = guide.layoutFrame.size
        fallOverlayView = UIView(frame: guide.layoutFrame)
        fallOverlayView.backgroundColor = .systemGray6.withAlphaComponent(0.9)
        
        let topLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        topLabel.text = "Alerting Emergency Contact"
        topLabel.textAlignment = .center
        topLabel.font = UIFont(name: "DIN Alternate Bold", size: 30)
        topLabel.numberOfLines = 0
        fallOverlayView.addSubview(topLabel)
        
        let countdownLabel = UILabel(frame: CGRect(x: 0, y: 75, width: frame.width, height: 50))
        countdownLabel.text = "15"
        countdownLabel.textAlignment = .center
        countdownLabel.textColor = .systemRed
        countdownLabel.font = .boldSystemFont(ofSize: 40)
        fallOverlayView.addSubview(countdownLabel)
        
        let cancelButton = UIButton(frame: CGRect(x: 20, y: frame.height - 70, width: frame.width - 40, height: 50))
        cancelButton.layer.cornerRadius = 10
        cancelButton.backgroundColor = .selectedBlueColor
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        cancelButton.addTarget(self, action: #selector(userDidCancelEmergencyCall), for: .touchUpInside)
        fallOverlayView.addSubview(cancelButton)
        
        darkOverlayView = UIView(frame: view.frame)
        darkOverlayView.backgroundColor = .systemGray6
        
        var secondsRemaining = 14
        //Timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if secondsRemaining > 0 {
                countdownLabel.text = "\(secondsRemaining)"
                secondsRemaining -= 1
            } else {
                countdownLabel.text = "0"
                self.fallTimer?.invalidate()
                self.shouldCallEmergencyContact()
            }
        }
    }
    
    @objc func shouldCallEmergencyContact() {
        if let email = Authentication.user?.email?.toLegalStorageEmail() {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let now = df.string(from: Date())
            RealtimeUpload.upload(data: [email : now], path: "rides/\(groupID!)/fall/")
        } else {
            userDidCancelEmergencyCall()
            showFailureToast(message: "No email available.")
        }
    }
    
    func userDidFall() {
        configureFallScreen()
        movementManager.stopAccelerometerUpdates()
        
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(darkOverlayView)
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(fallOverlayView)
    }
    
    @objc func userDidCancelEmergencyCall() {
        movementManager.startAccelerometerUpdates(to: .main) { data, error in
            if let error = error {
                print("error with accelerometer: \(error.localizedDescription)")
            }
            
            let acceleration = abs(data!.acceleration.z)

            if acceleration > 1.5 {
                self.consecutiveAccelerationRedFlags += 1
                print("red flag")
            } else {
                self.consecutiveAccelerationRedFlags = 0
            }
            
            if self.consecutiveAccelerationRedFlags >= 2 {
                print("proper fall")
                self.userDidFall()
            }
        }
        
        fallOverlayView.removeFromSuperview()
        darkOverlayView.removeFromSuperview()
        fallTimer?.invalidate()
        self.showAnimationToast(animationName: "MutePhone", message: "Cancelled Call.", color: .systemBlue, fontColor: .systemBlue, speed: 0.5)
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
