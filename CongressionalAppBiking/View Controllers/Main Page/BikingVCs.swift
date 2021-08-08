//
//  BikingVCs.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/25/21.
//

import UIKit
import CoreLocation
import MapKit

class BikingVCs: UIViewController {

    var rideType: RideType!
    var map: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var previousLatitude: Double! = 0.0, previousLongitude: Double! = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setUp(map: MKMapView, rideType: RideType) {
        self.map = map
        self.rideType = rideType
        
        self.customizeNavigationController()
        self.setUpUserLocation()
        
        map.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: Location Getters
extension BikingVCs: CLLocationManagerDelegate, MKMapViewDelegate {
    func setUpUserLocation() {
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        self.recenterCamera()
        map.showsUserLocation = true
        map.mapType = .mutedStandard
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        (previousLatitude, previousLongitude) = UserLocation.getUserCurrentLocation()
        
//        let userLocationImage = MKPointAnnotation()
//        userLocationImage.title = User.firstName + " " + User.lastName
//        userLocationImage.coordinate = locationManager.location!.coordinate
//        map.addAnnotation(userLocationImage)
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        guard !annotation.isKind(of: MKUserLocation.self) else {
//            return nil
//        }
//
//        let annotationIdentifier = "CurrentUsersImage"
//
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            annotationView!.canShowCallout = true
//        }
//        else {
//            annotationView!.annotation = annotation
//        }
//
//        annotationView!.image = User.profilePicture
//
//        annotationView!.centerOffset = CGPoint(x: 0, y: -20)
//        annotationView!.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//
//        annotationView!.layer.cornerRadius = annotationView!.frame.height/2
//        return annotationView
//    }
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
        let userLocation = locationManager.location ?? CLLocation(latitude: 0, longitude: 0)
        map.centerCameraTo(location: userLocation)
    }
    
}

