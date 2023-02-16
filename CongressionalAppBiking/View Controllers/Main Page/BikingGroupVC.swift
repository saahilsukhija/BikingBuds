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
import UserNotifications
import FirebaseMessaging
import FirebaseFunctions
import FirebaseDatabase

class BikingGroupVC: BikingVCs {
    
    @IBOutlet weak var mapView: MKMapView!
    var groupID: String!
    var groupName: String!
    var loadingView: UIView!
    var scrollView: UIScrollView!
    var fallTimer: Timer?
    var unreadNotifications = 0
    
    
    var pendingRWGPSLogin = false
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadingView = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingView)
        
        super.setUp(map: mapView)
        self.addGroupCodeToNavController()
        //self.setUpMotionManager()
        self.customizeNavigationController()
        
        registerForRemoteNotification()
        
        mapView.delegate = self
        mapView.register(GroupUserAnnotationView.self, forAnnotationViewWithReuseIdentifier: "groupUser")
        mapView.register(GroupUserAnnotationView.self, forAnnotationViewWithReuseIdentifier: "rwgpsDistanceMarker")
        
        if(Authentication.riderType == .rider) {
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
        } else {
            mapView.setUserTrackingMode(.none, animated: true)
        }
        
        navigationController?.navigationItem.title = groupName
        navigationController?.title = groupName
        
        Locations.resetGroupUsers(for: groupID)
        Locations.addNotifications(for: groupID)
        Locations.addNotificationsForAnnouncements(for: groupID)
        
        addObservers()
        
        pendingRWGPSLogin = true
        RWGPSUser.login { completed, error in
            self.pendingRWGPSLogin = false
            if !completed {
                print("error logging into RWGPS on viewdidload: \(error)")
            } else {
                NotificationCenter.default.post(name: .rwgpsUserLogin, object: nil)
            }
        }
        
        RWGPSRoute.addNotificationsForRouteUpdate(for: groupID)
        
        
        
        fallTimer = Timer()
        notificationCountLabel.isHidden = true
        
        loadingView.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager?.requestAlwaysAuthorization()
        if let location = locationManager.location?.coordinate {
            uploadUserLocation(location)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) { [self] in
            uploadUserLocation(CLLocationCoordinate2D(latitude: previousLatitude + 0.0001, longitude: previousLongitude + 0.0001))
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Locations.removeNotifications(for: groupID)
    }
    
    
}


//MARK: RWGPS
extension BikingGroupVC {
    @objc func displayRWGPSRoute() {
        
        mapView.removeOverlays(mapView.overlays)
        let points = RWGPSRoute.poi
        var locations: [CLLocationCoordinate2D] = []
        
        points.forEach { poi in
            locations.append(poi.coord)
        }
        
        mapView.drawRWGPSPoints(locations)
        
        for poi in RWGPSRoute.routeMarkers {
            let annotation = RWGPSDistanceMarkerAnnotation()
            annotation.title = "\(RWGPSRoute.metersToMiles(poi.distance).rounded()) miles"
            annotation.coordinate = poi.coord
            annotation.distance = RWGPSRoute.metersToMiles(poi.distance).rounded()
            mapView.addAnnotation(annotation)
        }
    }
    
    @objc func rwgpsRouteUpdated(_ notification: NSNotification) {
        guard let id = notification.userInfo?["id"] as? String else {
            print("error getting rwgps id from notification")
            return
        }
        
        guard pendingRWGPSLogin == false else { return }
        RWGPSRoute.getRouteDetails(from: id) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("ugh: \(error)")
                    self.showAnimationNotification(animationName: "OffRoute", message: "Someone in your group linked a RWGPS route, but you are not signed in. Please login to see the route.", duration: 15, fontsize: 16)
                    Locations.notifications.addNotification(email: Authentication.user?.email ?? "", title: "Someone linked a RWGPS Route!", subTitle: "Log into your RWGPS account to see it", type: .distanceTooFar)
                    self.unreadNotifications += 1
                    
                } else {
                    //self.showSuccessNotification(message: "")
                    NotificationCenter.default.post(name: .rwgpsRouteLoaded, object: nil)
                    
                    
                   // print(RWGPSRoute.title)
                }
            }
        }
        
        
    }
    
    @objc func rwgpsUserLogin() {
        guard let groupID = groupID else { return }
        
        let ref = Database.database().reference().child("rides/\(groupID)/rwgps_route/rwgps_id")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            
            if let id = snapshot.value as? String {
                NotificationCenter.default.post(name: .rwgpsUpdatedInGroup, object: nil, userInfo: ["id" : id])
            }
        }
    }
}

//MARK: User Location Base Functions
extension BikingGroupVC {
    
    @objc func userLocationsUpdated() {
        ((bottomSheet.contentViewController as? UINavigationController)?.viewControllers[0] as? BottomSheetInfoGroupVC)?.reloadGroupUsers()
        mapView.drawAllGroupMembers(includingSelf: false)
        
        updateNotificationCount()
    }
    
    @objc func otherUserLeftRemoveAnnotation() {
        mapView.removeGroupMember(email: Locations.notifications[0].email)
    }
    

    @objc func userIsNonRider() {
        previousLatitude = 0
        previousLongitude = 0
        locationManager.stopUpdatingLocation()
        
        try? UserDefaults.standard.set(object: RiderType.spectator, forKey: "rider_type")
    }
    
    @objc func userIsRider() {
        locationManager.startUpdatingLocation()
        
        try? UserDefaults.standard.set(object: RiderType.rider, forKey: "rider_type")
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
//        let email = Locations.recentFall.keys.first ?? "none"
//        print(email)
//        showAnimationNotification(animationName: "Caution", message: "\(Locations.groupUsers.groupUserFrom(email: email)?.displayName ?? email) has fallen!", duration: 20, color: .systemOrange, fontColor: .systemOrange)
//        updateNotificationCount()
    }
    
    func updateNotificationCount() {
        if unreadNotifications == 0 {
            notificationCountLabel.isHidden = true
        } else {
            notificationCountLabel.isHidden = false
            notificationCountLabel.text = /*"\(Locations.notifications.count + Locations.announcementNotifications.otherUsersAnnouncements().count)"*/ "\(unreadNotifications)"
        }
    }
    
    
    @objc func userIsTooFar() {
//        guard let notif = Locations.distanceNotifications.first else {
//            print("user too far error getting notif")
//            return
//        }
//
//        self.showAnimationNotification(animationName: "OffRoute", message: notif.title, duration: 5, color: .orange, fontColor: .orange)
    }
    
}


//MARK: Map Functions
extension BikingGroupVC {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("selectedAnnotation")
        
        
        guard let bottomSheetNav = (bottomSheet.contentViewController as? UINavigationController) else { return }
        
        if view as? MKUserLocationView != nil {
            guard let selectedEmail = Authentication.user?.email else { return }
            bottomSheetNav.popToRootViewController(animated: true)
            (bottomSheetNav.viewControllers[0] as! BottomSheetInfoGroupVC).mapSelectedPerson(selectedEmail)
        }
        else {
            guard let annotationView = view as? GroupUserAnnotationView else { return }
            guard let selectedEmail = (annotationView.annotation as? GroupUserAnnotation)?.email else { return }
            
            view.layer.zPosition = 100
            bottomSheetNav.popToRootViewController(animated: true)
            
            (bottomSheetNav.viewControllers[0] as! BottomSheetInfoGroupVC).mapSelectedPerson(selectedEmail)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("deselectedAnnotation")
        view.layer.zPosition = 0
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
        
        if groupUserAnnotationView.inSelectedState {
            groupUserAnnotationView.layer.zPosition = 100
        } else {
            groupUserAnnotationView.layer.zPosition = 0
        }
        mapView.drawGroupMember(email: groupUser.email, location: groupUserAnnotation.coordinate)
        
    }
}

//MARK: Initial Setup
extension BikingGroupVC {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .locationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .groupUsersUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(otherUserLeftRemoveAnnotation), name: .shouldResetMapAnnotations, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userIsRider), name: .userIsRider, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userIsNonRider), name: .userIsNonRider, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(otherUserHasFallen), name: .userHasFallen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newAnnouncement), name: .newAnnouncement, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceTokenLoaded), name: .deviceTokenLoaded, object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(userIsTooFar), name: .userIsTooFar, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rwgpsUserLogin), name: .rwgpsUserLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayRWGPSRoute), name: .rwgpsRouteLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rwgpsRouteUpdated(_:)), name: .rwgpsUpdatedInGroup, object: nil)
    }
    
    func addGroupCodeToNavController() {
        let groupCodeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width / 2, height: navigationController?.navigationBar.frame.size.height ?? 75))
        groupCodeLabel.font = UIFont(name: "Poppins-Medium", size: 18)
        groupCodeLabel.text = groupName
        groupCodeLabel.textColor = .black
        groupCodeLabel.textAlignment = .center
        
        groupCodeLabel.layer.cornerRadius = groupCodeLabel.frame.size.height / 2
        groupCodeLabel.dropShadow()
        //groupCodeLabel.layer.borderWidth = 1
        //groupCodeLabel.layer.borderColor = UIColor.black.cgColor
        
        groupCodeLabel.layer.backgroundColor = UIColor.white.cgColor
        
        navigationItem.titleView = groupCodeLabel
        
        configureAnnouncementView()
        configureInvitePeopleButton()
        configureLeaveGroupButton()
        
        
    }
    
    func configureInvitePeopleButton() {
        let titleAttribute = [ NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 18.0)! ]
        let attributedString = NSAttributedString(string: "Invite People", attributes: titleAttribute)
        
        let invitePeopleButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        invitePeopleButton.setImage(UIImage(systemName: "plus"), for: .normal)
        invitePeopleButton.setAttributedTitle(attributedString, for: .normal)
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
        let titleAttribute = [ NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 18.0)! ]
        let attributedString = NSAttributedString(string: "Leave Group", attributes: titleAttribute)
        
        let leaveGroupButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        leaveGroupButton.setImage(UIImage(systemName: "figure.wave"), for: .normal)
        leaveGroupButton.setAttributedTitle(attributedString, for: .normal)
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
    
    func customizeNavigationController() {
        self.navigationItem.largeTitleDisplayMode = .never
        
        //Fully Transparent Navigation Bar Background
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        let rightBarButtonCustomView = UIView(frame: CGRect(x: view.frame.size.width - 56, y: (UIApplication.shared.windows.first?.safeAreaInsets.top)! + 0, width: 40, height: 95))
        let settingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        settingsButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        settingsButton.backgroundColor = preferredBackgroundColor
        settingsButton.tintColor = .accentColor
    
        settingsButton.addTarget(self, action: #selector(openSettingsScreen), for: .touchUpInside)
        settingsButton.layer.cornerRadius = settingsButton.frame.size.height / 2
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = UIColor.label.cgColor
        settingsButton.layer.masksToBounds = true
        
        rightBarButtonCustomView.addSubview(settingsButton)
        
        //NotificationButton
        let notificationsButton = UIButton(frame: CGRect(x: 0, y: 45, width: 40, height: 40))
        notificationsButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        notificationsButton.backgroundColor = preferredBackgroundColor
        notificationsButton.tintColor = .accentColor

        notificationsButton.addTarget(self, action: #selector(openNotificationScreen), for: .touchUpInside)
        notificationsButton.layer.cornerRadius = notificationsButton.frame.size.height / 2
        notificationsButton.layer.borderWidth = 1
        notificationsButton.layer.borderColor = UIColor.label.cgColor
        notificationsButton.layer.masksToBounds = true
        
        rightBarButtonCustomView.addSubview(notificationsButton)

        self.navigationController?.view.addSubview(rightBarButtonCustomView)
        //Center camera
        let centerCameraButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        centerCameraButton.setImage(UIImage(systemName: "location"), for: .normal)
        centerCameraButton.backgroundColor = preferredBackgroundColor
        centerCameraButton.tintColor = .label
        
        centerCameraButton.addTarget(self, action: #selector(recenterCamera), for: .touchUpInside)
        centerCameraButton.layer.cornerRadius = centerCameraButton.frame.size.height / 2
        centerCameraButton.layer.borderWidth = 1
        centerCameraButton.layer.borderColor = UIColor.label.cgColor
        centerCameraButton.layer.masksToBounds = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: centerCameraButton)
    
        
        notificationCountLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        notificationCountLabel.backgroundColor = .systemRed
        notificationCountLabel.textColor = .white
        notificationCountLabel.text = "0"
        notificationCountLabel.textAlignment = .center
        notificationCountLabel.font = UIFont.systemFont(ofSize: 14)
        notificationCountLabel.layer.cornerRadius = 10
        notificationCountLabel.layer.masksToBounds = true
        notificationCountLabel.isUserInteractionEnabled = false
        
        rightBarButtonCustomView.addSubview(notificationCountLabel)
        notificationCountLabel.translatesAutoresizingMaskIntoConstraints = false
    
        let notificationCountConstraints: [NSLayoutConstraint] = [
            notificationCountLabel.bottomAnchor.constraint(equalTo: notificationsButton.topAnchor,
                                                       constant: 15),
            notificationCountLabel.rightAnchor.constraint(equalTo: notificationsButton.rightAnchor, constant: 0),
            notificationCountLabel.widthAnchor.constraint(equalToConstant: 20),
            notificationCountLabel.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        NSLayoutConstraint.activate(notificationCountConstraints)
    }
    
    @objc func openSettingsScreen() {
        let vc = storyboard?.instantiateViewController(identifier: "groupRideSettingsScreen") as! GroupRideSettingsVC
        vc.ride = Ride(id: groupID, name: groupName)
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func openNotificationScreen() {
        let vc = storyboard?.instantiateViewController(identifier: "NotificationsScreen") as! NotificationsVC
        unreadNotifications = 0
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func openAnnouncementScreen() {
        let vc = storyboard?.instantiateViewController(identifier: "AnnouncementScreen") as! AnnouncementVC
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @objc func endRide() {
        let bottomAlert = UIAlertController(title: "Are you sure you want to leave the group?", message: "You can join back in the future.", preferredStyle: .actionSheet)
        bottomAlert.addAction(UIAlertAction(title: "Save and Leave Group", style: .default, handler: { _ in
            self.saveThisRide()
            UserDefaults.standard.set(false, forKey: "is_in_group")
            UserDefaults.standard.removeObject(forKey: "rider_type")
            
            UserLocationsUpload.riderLeftGroup(group: self.groupID)
            
            Locations.notifications.removeAll()
            Locations.removeAnnouncementObservers(for: self.groupID)
            
            self.removePushNotificationReceivers()
            self.dismiss(animated: true, completion: nil)
            
        }))
        bottomAlert.addAction(UIAlertAction(title: "Leave Group", style: .destructive, handler: { _ in
            UserDefaults.standard.set(false, forKey: "is_in_group")
            UserDefaults.standard.removeObject(forKey: "rider_type")
            UserLocationsUpload.riderLeftGroup(group: self.groupID)
            
            Locations.notifications.removeAll()
            Locations.removeAnnouncementObservers(for: self.groupID)
            
            self.removePushNotificationReceivers()
            self.dismiss(animated: true, completion: nil)
        }))
        bottomAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(bottomAlert, animated: true, completion: nil)
    }
    
    func saveThisRide() {
        let ride = Ride(id: groupID, name: groupName)
        var previousSavedRides: [Ride] = []
        do {
            previousSavedRides = try UserDefaults.standard.get(objectType: [Ride].self, forKey: "saved_rides") ?? []
        } catch {
            self.showFailureToast(message: "Error saving ride")
            return
        }
        
        guard !previousSavedRides.containsRide(ride) else {
            self.showFailureToast(message: "Ride is already saved.")
            return
        }
        
        previousSavedRides.append(ride)
        self.showSuccessToast(message: "Ride is saved!")
        
        try? UserDefaults.standard.set(object: previousSavedRides, forKey: "saved_rides")
        print(previousSavedRides)
        
        
        
    }
    
}

//MARK: Announcement Functions
extension BikingGroupVC {
    func configureAnnouncementView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 55))
        scrollView.contentSize = CGSize(width: 5000, height: 55)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 5000, height: 55))
        scrollView.addSubview(view)
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = true
        
        bottomSheet.view.addSubview(scrollView)
        scrollView.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeG = self.view.safeAreaLayoutGuide
        let constraints: [NSLayoutConstraint] = [
            scrollView.bottomAnchor.constraint(equalTo: bottomSheet.surfaceView.topAnchor,
                                                       constant: -50),
            scrollView.heightAnchor.constraint(equalToConstant: 55),
            scrollView.leadingAnchor.constraint(equalTo: safeG.leadingAnchor, constant: 0.0),
            scrollView.trailingAnchor.constraint(equalTo: safeG.trailingAnchor, constant: 0.0),
            //view.widthAnchor.constraint(equalToConstant: 5000)
        ]

        NSLayoutConstraint.activate(constraints)
        
        
        let announcements = [("I got a flat!", "I got a flat!".width(withConstrainedHeight: 60)), ("Let's regroup!", "Let's regroup!".width(withConstrainedHeight: 60)), ("I need help!", "I need help!".width(withConstrainedHeight: 60)), ("I'm leaving!", "I'm leaving!".width(withConstrainedHeight: 60)), ("Finished!", "Finished!".width(withConstrainedHeight: 60)), ("Getting coffee!", "Getting coffee!".width(withConstrainedHeight: 60))]
        
        let customButton = UIButton(frame: CGRect(x: 10 , y: 5, width: " Custom".width(withConstrainedHeight: 60) + 40, height: 45))
        
        let titleAttribute = [ NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 16.0)! ]
        let attributedString = NSAttributedString(string: "Custom", attributes: titleAttribute)
        customButton.setAttributedTitle(attributedString, for: .normal)
        customButton.setImage(UIImage(systemName: "plus"), for: .normal)
        customButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        customButton.layer.cornerRadius = 22.5
        customButton.backgroundColor = .white
        customButton.setTitleColor(.black, for: .normal)
        customButton.layer.masksToBounds = false
        
        customButton.dropShadow()
        
        customButton.tag = announcements.count
        customButton.tintColor = .black
        
        customButton.addTarget(self, action: #selector(customAnnouncementButtonClicked), for: .touchUpInside)
        
        view.addSubview(customButton)
        
        var previousButton: UIButton? = customButton
        var lastButton: UIButton?
        for (index, announcement) in announcements.enumerated() {
            let button = UIButton(frame: CGRect(x: (previousButton?.frame.maxX ?? 0) + 10 , y: 5, width: announcement.1 + 20, height: 45))
            
            let titleAttribute = [ NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 16.0)! ]
            let attributedString = NSAttributedString(string: announcement.0, attributes: titleAttribute)
            button.setAttributedTitle(attributedString, for: .normal)
            
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            view.addSubview(button)
            let buttonConstraints: [NSLayoutConstraint] = [
                button.topAnchor.constraint(equalTo: scrollView.topAnchor,
                                                           constant: 5),
                button.leadingAnchor.constraint(equalTo: previousButton?.trailingAnchor ?? view.leadingAnchor, constant: 10),
                button.heightAnchor.constraint(equalToConstant: 45),
                button.widthAnchor.constraint(equalToConstant: announcement.1 + 20)
            ]
            NSLayoutConstraint.activate(buttonConstraints)
            
            button.layer.cornerRadius = 22.5
//            button.layer.borderWidth = 1
//            button.layer.borderColor = UIColor.systemGray.cgColor
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.layer.masksToBounds = false
            
            button.dropShadow()
            
            button.tag = index
            
            button.addTarget(self, action: #selector(premadeAnnouncementButtonClicked(_:)), for: .touchUpInside)
            previousButton = button
            
            if(index == announcements.count-1) {
                lastButton = button
            }
        }
        
        if let lastButton = lastButton {
            let lastButtonConstraints: [NSLayoutConstraint] = [
                lastButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor,
                                                  constant: -10)]
            NSLayoutConstraint.activate(lastButtonConstraints)
        }
 
        
    }
    
    @objc func premadeAnnouncementButtonClicked(_ sender: UIButton) {
        let announcements = ["I got a flat!", "Let's regroup!", "I need help!", "I'm leaving!", "Finished!", "Getting coffee!"]
        let vc = storyboard?.instantiateViewController(identifier: "AnnouncementScreen") as! AnnouncementVC
        vc.announcement = announcements[sender.tag]
        vc.group = groupID
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func customAnnouncementButtonClicked() {
        let vc = storyboard?.instantiateViewController(identifier: "AnnouncementScreen") as! AnnouncementVC
        self.present(vc, animated: true, completion: {
            vc.group = self.groupID
            vc.announcementTextField.becomeFirstResponder()
        })
    }
    
    @objc func newAnnouncement() {
        print("new announcement")
        
        if Locations.announcementNotifications.count > 0 {
            if Locations.announcementNotifications[0].email != Authentication.user?.email {
                unreadNotifications += 1
                self.showAnnouncementNotification(announcement: Locations.announcementNotifications[0])
            }
        }
    }
    
}

//MARK: Push Notifications
extension BikingGroupVC: UNUserNotificationCenterDelegate, MessagingDelegate {
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }

        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }

        if let groupID = groupID {
            Messaging.messaging().subscribe(toTopic: "\(groupID)_announcements") { error in
                print("Subscribed to \(groupID)_announcements for notifications")
            }
            Messaging.messaging().subscribe(toTopic: "\(groupID)_rwgpsRouteUpdates") { error in
                print("Subscribed to \(groupID)_rwgpsRouteUpdates for notifications")
            }
        }
        
        Messaging.messaging().delegate = self
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            //self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
          }
        }
    }
    
    @objc func deviceTokenLoaded() {
        UserLocationsUpload.uploadUserDeviceToken(group: groupID)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
          name: Notification.Name("FCMToken"),
          object: nil,
          userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
      }
    
    func removePushNotificationReceivers() {
        if let groupID = groupID {
            Messaging.messaging().unsubscribe(fromTopic: "\(groupID)_announcements") { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            Messaging.messaging().unsubscribe(fromTopic: "\(groupID)_rwgpsRouteUpdates") { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont = UIFont(name: "Poppins-Regular", size: 16.0)!) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont = UIFont(name: "Poppins-Regular", size: 16.0)!) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}

////MARK: Accelerometer Updates
//extension BikingGroupVC {
//    func setUpMotionManager() {
//
//        movementManager = CMMotionManager()
//        movementManager.accelerometerUpdateInterval = 0.1
//        movementManager.startAccelerometerUpdates(to: .main) { data, error in
//            if let error = error {
//                print("error with accelerometer: \(error.localizedDescription)")
//            }
//
//            let acceleration = abs(data!.acceleration.z)
//
//            if acceleration > 1.3 {
//                self.consecutiveAccelerationRedFlags += 1
//                print("red flag")
//            } else {
//                self.consecutiveAccelerationRedFlags = 0
//            }
//
//            if self.consecutiveAccelerationRedFlags >= 2 {
//                print("proper fall")
//
//                self.userDidFall()
//            }
//        }
//    }
//
//    func configureFallScreen() {
//        let guide = view.safeAreaLayoutGuide
//        let frame = guide.layoutFrame.size
//        fallOverlayView = UIView(frame: guide.layoutFrame)
//        fallOverlayView.backgroundColor = .systemGray6.withAlphaComponent(0.9)
//
//        let topLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60))
//        topLabel.text = "Detected a Fall.\n Alerting your group in:"
//        topLabel.textAlignment = .center
//        topLabel.font = UIFont(name: "Poppins-SemiBold", size: 30)
//        topLabel.numberOfLines = 0
//        fallOverlayView.addSubview(topLabel)
//
//        let countdownLabel = UILabel(frame: CGRect(x: 0, y: 75, width: frame.width, height: 50))
//        countdownLabel.text = "15"
//        countdownLabel.textAlignment = .center
//        countdownLabel.textColor = .systemRed
//        countdownLabel.font = .boldSystemFont(ofSize: 40)
//        fallOverlayView.addSubview(countdownLabel)
//
//        let cancelButton = UIButton(frame: CGRect(x: 20, y: frame.height - 70, width: frame.width - 40, height: 50))
//        cancelButton.layer.cornerRadius = 10
//        cancelButton.backgroundColor = .accentColor
//        cancelButton.setTitle("Cancel", for: .normal)
//        cancelButton.setTitleColor(.white, for: .normal)
//        cancelButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
//        cancelButton.addTarget(self, action: #selector(userDidCancelEmergencyCall), for: .touchUpInside)
//        fallOverlayView.addSubview(cancelButton)
//
//        darkOverlayView = UIView(frame: view.frame)
//        darkOverlayView.backgroundColor = .systemGray6
//
//        var secondsRemaining = 14
//        //Timer
//        fallTimer?.invalidate()
//        fallTimer = nil
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
//            self.fallTimer = timer
//            if secondsRemaining > 0 {
//                countdownLabel.text = "\(secondsRemaining)"
//                secondsRemaining -= 1
//            } else {
//                countdownLabel.text = "0"
//                timer.invalidate()
//                self.fallTimer?.invalidate()
//                self.fallTimer = nil
//                self.shouldCallEmergencyContact()
//            }
//        }
//    }
//
//    @objc func shouldCallEmergencyContact() {
//        if let email = Authentication.user?.email?.toLegalStorageEmail() {
//            let df = DateFormatter()
//            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            let now = df.string(from: Date())
//            RealtimeUpload.upload(data: [email : now], path: "rides/\(groupID!)/fall/")
//        } else {
//            userDidCancelEmergencyCall()
//            showFailureToast(message: "No email available.")
//        }
//    }
//
//    func userDidFall() {
//        configureFallScreen()
//        movementManager.stopAccelerometerUpdates()
//
//        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(darkOverlayView)
//        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(fallOverlayView)
//    }
//
//    @objc func userDidCancelEmergencyCall() {
//        movementManager.startAccelerometerUpdates(to: .main) { data, error in
//            if let error = error {
//                print("error with accelerometer: \(error.localizedDescription)")
//            }
//
//            let acceleration = abs(data!.acceleration.z)
//
//            if acceleration > 1.5 {
//                self.consecutiveAccelerationRedFlags += 1
//                print("red flag")
//            } else {
//                self.consecutiveAccelerationRedFlags = 0
//            }
//
//            if self.consecutiveAccelerationRedFlags >= 2 {
//                print("proper fall")
//                self.userDidFall()
//            }
//        }
//
//        fallOverlayView.removeFromSuperview()
//        darkOverlayView.removeFromSuperview()
//        fallTimer?.invalidate()
//        fallTimer = nil
//        self.showAnimationToast(animationName: "MutePhone", message: "Cancelled Call.", color: .systemBlue, fontColor: .systemBlue, speed: 0.5)
//    }
//}
