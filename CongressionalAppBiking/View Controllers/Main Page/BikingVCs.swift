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
        if bottomSheet.nearbyState == .tip {
            bottomSheet.move(to: .half, animated: true)
        }
    }
    
    func customizeBottomSheet() {
        // Create a new appearance.
        let appearance = SurfaceAppearance()

        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]

        // Define corner radius and background color
        appearance.cornerRadius = 8.0
        appearance.backgroundColor = .clear

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
        map.showsUserLocation = true
        map.mapType = .mutedStandard
    
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            
        case .notDetermined, .restricted, .denied:
            showFailureToast(message: "Unable to show map")
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
        
        //End Ride Button
        let endRideButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        endRideButton.backgroundColor = .systemRed
        endRideButton.tintColor = .white
        endRideButton.setTitle("End Ride", for: .normal)
        
        endRideButton.addTarget(self, action: #selector(endRide), for: .touchUpInside)
        endRideButton.layer.cornerRadius = 10
        endRideButton.layer.masksToBounds = true
        
        
        let endRideBarButton = UIBarButtonItem(customView: endRideButton)
        self.navigationItem.rightBarButtonItem = endRideBarButton
        
        //Center camera
        let centerCameraButton = UIBarButtonItem(image: UIImage(systemName: "location.north.fill"), style: .plain, target: self, action: #selector(recenterCamera))
        centerCameraButton.tintColor = .label
        self.navigationItem.leftBarButtonItem = centerCameraButton
        
    }
    
    @objc func endRide() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func recenterCamera() {
        let userLocation = locationManager.location?.coordinate.roundTo(places: Preferences.coordinateRoundTo) ?? map.userLocation.coordinate
        map.centerCameraTo(location: userLocation)
        userHasPannedAway = false
    }
    
}

