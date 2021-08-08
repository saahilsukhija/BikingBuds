//
//  BikingVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/9/21.
//

import UIKit
import CoreLocation
import MapKit

class BikingGroupVC: BikingVCs {
    
    @IBOutlet weak var mapView: MKMapView!
    var groupID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setUp(map: mapView, rideType: .group)
        Locations.addNotifications(for: groupID)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .locationUpdated, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uploadUserLocation()
    }
    
    @objc func userLocationsUpdated() {
        mapView.drawAllGroupMembers(includingSelf: false)
    }
    
    override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        super.locationManager(manager, didUpdateLocations: locations)
        
        let latitude = locations[0].coordinate.latitude.roundTo(places: 4)
        let longitude = locations[0].coordinate.longitude.roundTo(places: 4)
        
        if previousLatitude != latitude || previousLongitude != longitude {
            uploadUserLocation()
        } else {
            //Same Location, not uploading to cloud
        }
    }
    
    func uploadUserLocation() {
        UserLocationsUpload.uploadCurrentLocation(group: groupID) { completed, message in
            if !completed {
                print(message!)
            }
        }
    }
    

}
