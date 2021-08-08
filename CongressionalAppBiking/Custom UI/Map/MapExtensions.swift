//
//  MapExtensions.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/29/21.
//

import MapKit
import FirebaseAuth
extension MKMapView {
    
    /// Center the camera to a specific point
    /// - Parameters:
    ///   - location: The center of the camera
    ///   - regionRadius: The zoom level/How much is being shown at once, defaults at 1000
    func centerCameraTo(location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
    
    /// Draw all points on the map representing all group members
    /// - Parameter includingSelf: Draw Current User on the map as well (defaulted to false)
    func drawAllGroupMembers(includingSelf: Bool = false) {
        var locations = Locations.locations!
        
        //Remove current user (only if you don't want to draw the current user)
        if !includingSelf {
            locations.removeValue(forKey: Auth.auth().currentUser!.email!)
        }
        
        for (email, location) in locations {
            drawGroupMember(email: email, location: location)
        }
    }
    
    
    /// Draw point on the map for a user representing their location
    /// - Parameters:
    ///   - email: The email of the user to draw
    ///   - location: The location of the user to draw
    func drawGroupMember(email: String, location: CLLocationCoordinate2D) {
        let locationPoint = MKPointAnnotation()
        locationPoint.coordinate = location
        locationPoint.title = email
        self.addAnnotation(locationPoint)
    }
}
