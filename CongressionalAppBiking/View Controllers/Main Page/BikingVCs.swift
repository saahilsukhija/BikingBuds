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
    //var movementManager: CMMotionManager!
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
        //movementManager.stopAccelerometerUpdates()
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
        
        bottomSheet.layout = MyFloatingPanelLayout()
    }
    
    func floatingPanelWillEndDragging(_ fpc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
        if targetState.pointee == FloatingPanelState.tip || targetState.pointee == FloatingPanelState.half {
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
//                locationManager.requestAlwaysAuthorization()
                locationManager.showsBackgroundLocationIndicator = true
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.startUpdatingLocation()
                locationManager.distanceFilter = Preferences.distanceFilter
            }
            
        } else {
            print("BikingVCs location services not enabled")
        }
        map.showsUserLocation = true
        self.recenterCamera()
        
    
        
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
        
        //manager.requestAlwaysAuthorization()
    }
    
    func updatePreviousLocations(_ coordinate: CLLocationCoordinate2D) {
        
        if !userHasPannedAway {
            self.recenterCamera()
        }
        (previousLatitude, previousLongitude) = (coordinate.latitude, coordinate.longitude)
    }
    
    
    @objc func recenterCamera() {
//        if(Authentication.riderType == .rider) {
//            let userLocation = locationManager.location?.coordinate.roundTo(places: Preferences.coordinateRoundTo) ?? map.userLocation.coordinate
//            map.centerCameraTo(location: userLocation)
//        } else {
//            map.showAnnotations(map.annotations, animated: true)
// //            var otherRiderLocation: CLLocationCoordinate2D?
// //            for (user, type) in Locations.riderTypes {
// //                if(type == .rider) {
// //                    otherRiderLocation = Locations.locations[user]
// //                    break
// //                }
// //            }
//            //= valuesArray.first(where: {$0.latitude != 0 || $0.longitude != 0}
//            //)?.roundTo(places: Preferences.coordinateRoundTo) ?? CLLocationCoordinate2D(latitude: 39.8355, longitude: -99.09)
// //            if let otherRiderLocation = otherRiderLocation {
// //                map.centerCameraTo(location: otherRiderLocation)
// //                print("centering to \(otherRiderLocation)")
// //
// //            } else {
// //                map.showAnnotations(map.annotations, animated: true)
// //                map.centerCameraTo(location: CLLocationCoordinate2D(latitude: 39.8355, longitude: -99.09), regionRadius: 4600000)
// //                print("centering to US map")
// //            }
//        }
        
        if(Authentication.riderType == .rider) {
            map.setUserTrackingMode(.followWithHeading, animated: true)
        } else {
            //Center at random person
            if let firstPerson = Locations.locations.values.first(where: {$0.latitude != 0 || $0.longitude != 0})?.roundTo(places: Preferences.coordinateRoundTo) {
                map.centerCameraTo(location: firstPerson, regionRadius: 1000)
            }
            else {
                map.centerCameraTo(location: CLLocationCoordinate2D(latitude: 39.8355, longitude: -99.09), regionRadius: 4600000)
                map.setUserTrackingMode(.followWithHeading, animated: true)
                print("centering to US map")
            }
        }
        
        
        
        self.navigationItem.leftBarButtonItem?.customView?.tintColor = .accentColor
        (self.navigationItem.leftBarButtonItem?.customView as? UIButton)?.setImage(UIImage(systemName: "location.fill"), for: .normal)
        //map.drawAllGroupMembers(includingSelf: true)
        userHasPannedAway = false
    }
}

extension BikingVCs: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //print("HERE")
        guard !annotation.isKind(of: MKUserLocation.self) else {
            //print("SHIT")
            return nil
        }

        var annotationView: MKAnnotationView!
        var annotationIdentifier: String!

        if annotation.isKind(of: GroupUserAnnotation.self) {
            //print("groupuser")
            annotationIdentifier = "groupUser"
            annotationView = GroupUserAnnotationView(annotation: annotation as! GroupUserAnnotation, reuseIdentifier: annotationIdentifier)
            annotationView.frame = (annotationView as! GroupUserAnnotationView).containerView.frame

        } else if annotation.isKind(of: RWGPSDistanceMarkerAnnotation.self) {
            
                //print("rwgpsPoint")
                annotationIdentifier = "rwgpsDistanceMarker"
                annotationView = RWGPSDistanceMarkerAnnotationView(annotation: annotation as! RWGPSDistanceMarkerAnnotation, reuseIdentifier: annotationIdentifier)
                annotationView.frame = (annotationView as! RWGPSDistanceMarkerAnnotationView).containerView.frame

        } else {
            //print("marker")
            annotationIdentifier = "marker"
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }


        return annotationView
    }
    
    //User has panned away
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        userHasPannedAway = true
        self.navigationItem.leftBarButtonItem?.customView?.tintColor = .label
        (self.navigationItem.leftBarButtonItem?.customView as? UIButton)?.setImage(UIImage(systemName: "location"), for: .normal)
    }
    
    //RWGPS Route Line
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = .orange.withAlphaComponent(0.95)
            renderer.lineWidth = 10
            return renderer
        }

        return MKOverlayRenderer()
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

class MyFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(fractionalInset: 0.25, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.25, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
