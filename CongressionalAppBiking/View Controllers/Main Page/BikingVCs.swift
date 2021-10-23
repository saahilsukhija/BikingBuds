//
//  BikingVCs.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/25/21.
//

import UIKit
import CoreLocation
import CoreMotion
import MapKit
import FloatingPanel

class BikingVCs: UIViewController {

    var map: MKMapView!
    
    var userHasPannedAway: Bool! = false
    var locationManager: CLLocationManager!
    var movementManager: CMMotionManager!
    var previousLatitude: Double! = 0.0, previousLongitude: Double! = 0.0
    var consecutiveAccelerationRedFlags = 0
    var bottomSheet: FloatingPanelController!
    
    var preferredBackgroundColor: UIColor!
    
    var fallOverlayView: UIView!
    var darkOverlayView: UIView!
    
    var notificationCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        preferredBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemGray6 : .white
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        movementManager.stopAccelerometerUpdates()
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        
    }
    
    func setUp(map: MKMapView) {
        self.map = map
    
        self.map.delegate = self
        
        self.addBottomSheet()
        self.customizeNavigationController()
        self.setUpUserLocation()
        self.hideKeyboardWhenTappedAround()
        
    }
    

}

//MARK: Bottom Sheet
extension BikingVCs: FloatingPanelControllerDelegate {
    func addBottomGroupSheet() {
        bottomSheet = FloatingPanelController(delegate: self)
        let bottomSheetVC = UIStoryboard(name: "GroupBottomSheet", bundle: nil).instantiateViewController(identifier: "groupBottomSheetNav") as! UINavigationController
        (bottomSheetVC.topViewController as! BottomSheetInfoGroupVC).backdropView = self
        bottomSheet.set(contentViewController: bottomSheetVC)
        bottomSheet.contentMode = .fitToBounds
        customizeBottomSheet()
        
        bottomSheet.addPanel(toParent: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bottomSheetSearchBarClicked), name: .searchBarClicked, object: nil)
    }
    
    @objc func bottomSheetSearchBarClicked() {
        bottomSheet.move(to: .full, animated: true)
    }
    
    func customizeBottomSheet() {
        // Create a new appearance.
        let appearance = SurfaceAppearance()

        // Define corner radius and background color
        appearance.cornerRadius = 30
        appearance.backgroundColor = preferredBackgroundColor

        // Set the new appearance
        bottomSheet.surfaceView.contentPadding = .init(top: 10, left: 0, bottom: 0, right: 0)
        bottomSheet.surfaceView.appearance = appearance
    }
    
    func floatingPanelWillEndDragging(_ fpc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
        if targetState.pointee == FloatingPanelState.tip {
            self.dismissKeyboard()
        }
    }
    
    func addBottomSheet() {
        self.addBottomGroupSheet()
    }
}
//MARK: Location Getters
extension BikingVCs: CLLocationManagerDelegate {
    func setUpUserLocation() {
    
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.activityType = .fitness
            
            if Authentication.riderType == .rider {
                locationManager.requestAlwaysAuthorization()
                locationManager.showsBackgroundLocationIndicator = true
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.startUpdatingLocation()
            }
            
        } else {
            print("BikingVCs location services not enabled")
        }
        
        self.recenterCamera()
        map.showsUserLocation = false
    
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .restricted, .denied:
            Alert.showDefaultAlert(title: "Restricted/Denied location services", message: "You have restricted/denied the location services. Go into settings and enable them for BikingBuds", self)
        case .authorizedAlways, .authorizedWhenInUse :
            self.recenterCamera()
        default:
            self.recenterCamera()
        }
        
        manager.requestAlwaysAuthorization()
    }
    
    func updatePreviousLocations(_ coordinate: CLLocationCoordinate2D) {
        
        if !userHasPannedAway {
            self.recenterCamera()
        }
        (previousLatitude, previousLongitude) = (coordinate.latitude, coordinate.longitude)
    }
}

extension BikingVCs: MKMapViewDelegate {
    //User has panned away
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        userHasPannedAway = true
        self.navigationItem.leftBarButtonItem?.customView?.tintColor = .label
        (self.navigationItem.leftBarButtonItem?.customView as? UIButton)?.setImage(UIImage(systemName: "location"), for: .normal)
    }
}

//MARK: Initial Setup
extension BikingVCs {
    
    func customizeNavigationController() {
        self.navigationItem.largeTitleDisplayMode = .never
        
        //Fully Transparent Navigation Bar Background
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        let rightBarButtonCustomView = UIView(frame: CGRect(x: view.frame.size.width - 55, y: navigationController!.navigationBar.globalFrame!.maxY + 5, width: 40, height: 90))
        
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
        
        //NotificationButtun
        let notificationsButton = UIButton(frame: CGRect(x: 0, y: 50, width: 40, height: 40))
        notificationsButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        notificationsButton.backgroundColor = preferredBackgroundColor
        notificationsButton.tintColor = .accentColor

        notificationsButton.addTarget(self, action: #selector(openNotificationScreen), for: .touchUpInside)
        notificationsButton.layer.cornerRadius = notificationsButton.frame.size.height / 2
        notificationsButton.layer.borderWidth = 1
        notificationsButton.layer.borderColor = UIColor.label.cgColor
        notificationsButton.layer.masksToBounds = true
        
        rightBarButtonCustomView.addSubview(notificationsButton)
        
        view.addSubview(rightBarButtonCustomView)
        
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
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func openNotificationScreen() {
        let vc = storyboard?.instantiateViewController(identifier: "NotificationsScreen") as! NotificationsVC
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func endRide() {
        let bottomAlert = UIAlertController(title: "Are you sure you want to leave the group?", message: "You can join back in the future.", preferredStyle: .actionSheet)
        bottomAlert.addAction(UIAlertAction(title: "Leave Group", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        bottomAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(bottomAlert, animated: true, completion: nil)
    }
    
    @objc func recenterCamera() {
        let userLocation = locationManager.location?.coordinate.roundTo(places: Preferences.coordinateRoundTo) ?? map.userLocation.coordinate
        map.centerCameraTo(location: userLocation, bottomSheet: bottomSheet)
        self.navigationItem.leftBarButtonItem?.customView?.tintColor = .accentColor
        (self.navigationItem.leftBarButtonItem?.customView as? UIButton)?.setImage(UIImage(systemName: "location.fill"), for: .normal)
        userHasPannedAway = false
    }
    
    
}

extension UIView{
    var globalPoint :CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }

    var globalFrame :CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }
}

