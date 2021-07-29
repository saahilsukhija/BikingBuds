//
//  BikingVCs.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/25/21.
//

import UIKit
import CoreLocation
import GoogleMaps
class BikingVCs: UIViewController {

    var rideType: RideType!
    var locationManager: CLLocationManager!
    var mapView: GMSMapView!
    var userLocation: GMSMarker!
    var userCamera: GMSCameraPosition!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.customizeNavigationController()
        self.setUpUserLocation()
        
        self.view.addSubview(mapView)
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
        }
        
        let userLocation = locationManager.location?.coordinate
        userCamera = GMSCameraPosition.camera(withLatitude: userLocation?.latitude ?? 0, longitude: userLocation?.longitude ?? 0, zoom: 16)
        
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: userCamera)
        mapView.isIndoorEnabled = false
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
    }
}
//MARK: Initial Setup
extension BikingVCs {
    func customizeNavigationController() {
        self.navigationItem.largeTitleDisplayMode = .never
        
        //Fully Transparent Navigation Bar Background
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barTintColor = .gray
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .white
        
        //End Ride Button
        let endRideLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        endRideLabel.backgroundColor = .systemRed
        endRideLabel.textColor = .white
        endRideLabel.text = "End Ride"
        endRideLabel.font = UIFont(name: "Helvetica Neue Bold", size: 15)
        endRideLabel.textAlignment = .center
        endRideLabel.layer.cornerRadius = 10
        endRideLabel.layer.masksToBounds = true
        
        
        let endRideButton = UIBarButtonItem(customView: endRideLabel)
        endRideButton.target = self
        endRideButton.action = #selector(endRide)
        self.navigationItem.rightBarButtonItem = endRideButton
        
        
        //Center Map To User Marker
        let centerMapButton = UIBarButtonItem(image: UIImage(systemName: "pin.fill"), style: .plain, target: self, action: #selector(centerCameraToUser))
        centerMapButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = centerMapButton
    }
    
    @objc func endRide() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func centerCameraToUser() {
        if let userLocation = locationManager.location?.coordinate {
            mapView.animate(toLocation: userLocation)
            mapView.animate(toZoom: 16)
        }
    }
}

