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
    
    
    @objc func recenterCamera() {
        let userLocation = locationManager.location?.coordinate.roundTo(places: Preferences.coordinateRoundTo) ?? map.userLocation.coordinate
        map.centerCameraTo(location: userLocation, bottomSheet: bottomSheet)
        self.navigationItem.leftBarButtonItem?.customView?.tintColor = .accentColor
        (self.navigationItem.leftBarButtonItem?.customView as? UIButton)?.setImage(UIImage(systemName: "location.fill"), for: .normal)
        userHasPannedAway = false
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

extension UIView{
    var globalPoint :CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }

    var globalFrame :CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }
}

