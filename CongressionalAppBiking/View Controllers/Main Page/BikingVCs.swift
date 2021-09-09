//
//  BikingVCs.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/25/21.
//

import UIKit
import CoreLocation
import MapKit
import FloatingPanel

class BikingVCs: UIViewController {

    var rideType: RideType!
    var map: MKMapView!
    
    var userHasPannedAway: Bool! = false
    var locationManager: CLLocationManager!
    var previousLatitude: Double! = 0.0, previousLongitude: Double! = 0.0
    
    var bottomSheet: FloatingPanelController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
    }
    
    func setUp(map: MKMapView, rideType: RideType) {
        self.map = map
        self.rideType = rideType
    
        self.map.delegate = self
        
        self.customizeNavigationController()
        self.setUpUserLocation()
        self.addBottomSheet()
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

//        // Define shadows
//        let shadow = SurfaceAppearance.Shadow()
//        shadow.color = .black
//        shadow.offset = CGSize(width: 0, height: 12)
//        shadow.radius = 12
//        shadow.spread = 8
//        appearance.shadows = [shadow]

        // Define corner radius and background color
        appearance.cornerRadius = 8.0
        appearance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemGray5 : .white

        // Set the new appearance
        bottomSheet.surfaceView.contentPadding = .init(top: 10, left: 0, bottom: 0, right: 0)
        bottomSheet.surfaceView.containerView.layer.cornerRadius = 30
        bottomSheet.surfaceView.appearance = appearance
    }
    
    func floatingPanelWillEndDragging(_ fpc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
        if targetState.pointee == FloatingPanelState.tip {
            self.dismissKeyboard()
        }
    }
    
    func addBottomSheet() {
        if rideType == .group {
            self.addBottomGroupSheet()
        }
    }
    
    
    
    
    
}
//MARK: Location Getters
extension BikingVCs: CLLocationManagerDelegate {
    func setUpUserLocation() {
    
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.showsBackgroundLocationIndicator = true;
            locationManager.startUpdatingLocation()
        } else {
            print("BikingVCs location services not enabled")
        }
        
        self.recenterCamera()
        map.showsUserLocation = false
        map.mapType = .mutedStandard
    
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            
        case .notDetermined, .restricted, .denied:
            manager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse :
            self.recenterCamera()
        default:
            self.recenterCamera()
        }
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
        
        
        let settingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        settingsButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        settingsButton.backgroundColor = .systemBackground
        settingsButton.tintColor = .accentColor
    
        settingsButton.addTarget(self, action: #selector(openSettingsScreen), for: .touchUpInside)
        settingsButton.layer.cornerRadius = settingsButton.frame.size.height / 2
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = UIColor.label.cgColor
        settingsButton.layer.masksToBounds = true
        
        
        let invitePeopleButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        invitePeopleButton.setImage(UIImage(systemName: "person.crop.circle.fill.badge.plus"), for: .normal)
        invitePeopleButton.backgroundColor = .systemBackground
        invitePeopleButton.tintColor = .accentColor
    
        invitePeopleButton.addTarget(self, action: #selector(openInvitePeopleScreen), for: .touchUpInside)
        invitePeopleButton.layer.cornerRadius = invitePeopleButton.frame.size.height / 2
        invitePeopleButton.layer.borderWidth = 1
        invitePeopleButton.layer.borderColor = UIColor.label.cgColor
        invitePeopleButton.layer.masksToBounds = true
        
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: settingsButton), UIBarButtonItem(customView: invitePeopleButton)], animated: true)
        
        //Center camera
        let centerCameraButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        centerCameraButton.setImage(UIImage(systemName: "location"), for: .normal)
        centerCameraButton.backgroundColor = .systemBackground
        centerCameraButton.tintColor = .label
        
        centerCameraButton.addTarget(self, action: #selector(recenterCamera), for: .touchUpInside)
        centerCameraButton.layer.cornerRadius = centerCameraButton.frame.size.height / 2
        centerCameraButton.layer.borderWidth = 1
        centerCameraButton.layer.borderColor = UIColor.label.cgColor
        centerCameraButton.layer.masksToBounds = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: centerCameraButton)
        
    }
    
    @objc func openSettingsScreen() {
        let vc = storyboard?.instantiateViewController(identifier: "groupRideSettingsScreen") as! GroupRideSettingsVC
        self.present(vc, animated: true, completion: nil)
        //endRide()
    }
    
    @objc func openInvitePeopleScreen() {
        
    }
    
    @objc func endRide() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func recenterCamera() {
        let userLocation = locationManager.location?.coordinate.roundTo(places: Preferences.coordinateRoundTo) ?? map.userLocation.coordinate
        map.centerCameraTo(location: userLocation, bottomSheet: bottomSheet)
        self.navigationItem.leftBarButtonItem?.customView?.tintColor = .accentColor
        (self.navigationItem.leftBarButtonItem?.customView as? UIButton)?.setImage(UIImage(systemName: "location.fill"), for: .normal)
        userHasPannedAway = false
    }
    
}

