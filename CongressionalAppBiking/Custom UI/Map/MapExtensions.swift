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
    func centerCameraTo(location: CLLocationCoordinate2D, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
    
    /// Draw all points on the map representing all group members
    /// - Parameter includingSelf: Draw Current User on the map as well (defaulted to false)
    func drawAllGroupMembers(includingSelf: Bool = true) {
        
        removeAnnotations(annotations)
        var locations = Locations.locations!
        
        //Remove current user (only if you don't want to draw the current user)
        if !includingSelf {
            if let currentGroupUser = Locations.groupUsers.groupUserFrom(email: (Authentication.user?.email)!) {
                locations.removeValue(forKey: currentGroupUser)
            }
        }
        
        for (user, location) in locations {
            drawGroupMember(email: user.email, location: location)
        }
        
        
//        print("all group user annotations now: ")
//        annotations.forEach { annotation in
//            if let groupUserAnnotation = annotation as? GroupUserAnnotation {
//                print(groupUserAnnotation.email!)
//            } else {
//                print("not group user annotation")
//            }
//        }
//
//        if locations.count == 0 {
//            print("no locations")
//        }
//
//        if Locations.groupUsers.count == 0 {
//            print("no groupUsers")
//        }
    
    }
    
    /// Draw point on the map for a user representing their location
    /// - Parameters:
    ///   - email: The email of the user to draw
    ///   - location: The location of the user to draw
    func drawGroupMember(email: String, location: CLLocationCoordinate2D) {
        let locationPoint = GroupUserAnnotation()
        locationPoint.coordinate = location//annotationAlreadyExists(at: location).1
        locationPoint.email = email
        locationPoint.image = Locations.groupUsers.groupUserFrom(email: email)!.profilePicture!.toImage()
        locationPoint.title = email
        
        let tempMarkerPoint = MKPointAnnotation()
        tempMarkerPoint.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        tempMarkerPoint.title = email
        
        self.addAnnotation(locationPoint)
    }
    
    
    /// Used to not overlap annotations.
    /// - Parameter location: Location of the annotation to plot
    /// - Returns: Bool: If the location exists for a different annotation. Coordinate: If a location does already exist, returns the new coordinate. Defaults to the parameter
    func annotationAlreadyExists(at location: CLLocationCoordinate2D) -> (Bool, CLLocationCoordinate2D) {
        
        var locationAlreadyExists = false
        var newLocation = location
        
        
        
        for annotation in annotations {
            
            
            if annotation.coordinate.latitude == location.latitude && annotation.coordinate.longitude == location.longitude {
                print("location: \(location) + already exists")
                locationAlreadyExists = true
                
                let newLocationApproximation = CLLocationCoordinate2DMake(
                    annotation.coordinate.latitude + Double.random(in: -0.0005...0.0005), annotation.coordinate.longitude + Double.random(in: -0.0005...0.0005))
                
                if !annotationAlreadyExists(at: newLocationApproximation).0 {
                    //newLocationApproximation is not taken up
                    newLocation = newLocationApproximation
                    print("location after relocating: \(newLocation)")
                    return (locationAlreadyExists, newLocation)
                }
            }
        }
        
        return (locationAlreadyExists, newLocation)
    }
}

extension CLLocationCoordinate2D {
    
    /// Rounds the latitude and longitude to given places
    /// - Parameter places: The amount of decimal places.
    func roundTo(places: Int) -> CLLocationCoordinate2D {
        let latitude = latitude.roundTo(places: places)
        let longitude = longitude.roundTo(places: places)
        
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}
