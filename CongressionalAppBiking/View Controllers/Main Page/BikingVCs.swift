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
extension BikingVCs: CLLocationManagerDelegate {
    func setUpUserLocation() {
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            print("BikingVCs location services not enabled")
        }
        
        self.recenterCamera()
        map.showsUserLocation = true
        map.mapType = .mutedStandard
    
        
    }
    
    func updatePreviousLocations(_ coordinate: CLLocationCoordinate2D) {
        (previousLatitude, previousLongitude) = (coordinate.latitude, coordinate.longitude)
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
        let userLocation = locationManager.location ?? CLLocation(latitude: 0, longitude: 0)
        map.centerCameraTo(location: userLocation)
    }
    
}

