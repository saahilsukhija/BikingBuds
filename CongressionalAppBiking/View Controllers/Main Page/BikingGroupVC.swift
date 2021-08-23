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
    var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingView)
        
        super.setUp(map: mapView, rideType: .group)
        mapView.delegate = self
        mapView.register(GroupUserAnnotationView.self, forAnnotationViewWithReuseIdentifier: "groupUser")
        mapView.showsUserLocation = true
        navigationController?.navigationItem.title = groupID
        Locations.addNotifications(for: groupID)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .locationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .groupUsersUpdated, object: nil)
        
        loadingView.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uploadUserLocation(locationManager.location!.coordinate)
    }
    
    deinit {
        Locations.removeNotifications(for: groupID)
    }
    
    @objc func userLocationsUpdated() {
        mapView.drawAllGroupMembers(includingSelf: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latitude = locations[0].coordinate.latitude.roundTo(places: 4)
        let longitude = locations[0].coordinate.longitude.roundTo(places: 4)
        
        if previousLatitude != latitude || previousLongitude != longitude {
            uploadUserLocation(CLLocationCoordinate2DMake(latitude, longitude))
            print("previousCoordinate = \(previousLatitude ?? 0), \(previousLongitude ?? 0)")
            print("nowCoordinate = \(latitude), \(longitude)")
        } else {
            //Same Location, not uploading to cloud
        }
        
        super.updatePreviousLocations(CLLocationCoordinate2DMake(latitude, longitude))
    }
    
    func uploadUserLocation(_ location: CLLocationCoordinate2D) {
        UserLocationsUpload.uploadCurrentLocation(group: groupID, location: location) { completed, message in
            if !completed {
                print(message!)
            }
        }
    }
    
    
}

extension BikingGroupVC: MKMapViewDelegate {

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        var annotationView: MKAnnotationView!
        var annotationIdentifier: String!
        
        if annotation.isKind(of: GroupUserAnnotation.self) {
            annotationIdentifier = "groupUser"
            annotationView = GroupUserAnnotationView(annotation: annotation as! GroupUserAnnotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .close)
        } else {
            annotationIdentifier = "marker"
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        //print(annotationIdentifier + " annotation added")
        
        return annotationView
    }
    
}
