//
//  MapExtensions.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/29/21.
//

import MapKit
import FirebaseAuth
import FloatingPanel

extension MKMapView {
    
    /// Center the camera to a specific point
    /// - Parameters:
    ///   - location: The center of the camera
    ///   - regionRadius: The zoom level/How much is being shown at once, defaults at 1000
    func centerCameraTo(location: CLLocationCoordinate2D, regionRadius: CLLocationDistance = 1000, bottomSheet: FloatingPanelController? = nil) {
        
        let centerWithInset = CLLocationCoordinate2DMake(location.latitude - self.region.span.latitudeDelta * 0.3, location.longitude)
        let coordinateRegion = MKCoordinateRegion(center: centerWithInset,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
    
    /// Draw all points on the map representing all group members
    /// - Parameter includingSelf: Draw Current User on the map as well (defaulted to false)
    func drawAllGroupMembers(includingSelf: Bool = true) {
        
        var locations: [GroupUser : CLLocationCoordinate2D] = Locations.locations ?? [:]
        let riderTypes: [GroupUser : RiderType] = Locations.riderTypes ?? [:]
        
        //Remove current user (only if you don't want to draw the current user)
        if !includingSelf {
            if let currentGroupUser = Locations.groupUsers.groupUserFrom(email: Authentication.user?.email ?? "") {
                locations.removeValue(forKey: currentGroupUser)
            }
        }
        
        for (user, location) in locations {
            if riderTypes[user] == .rider {
                drawGroupMember(email: user.email, location: location)
            } else {
                removeGroupMember(email: user.email)
            }
        }
    
    }
    
    /// Draw point on the map for a user representing their location
    /// - Parameters:
    ///   - email: The email of the user to draw
    ///   - location: The location of the user to draw
    func drawGroupMember(email: String, location: CLLocationCoordinate2D) {
        
        if annotations.numberOfAnnotations(for: email) > 0 {
            annotations.getGroupUserAnnotation(for: email)!.coordinate = location
            self.view(for: annotations.getGroupUserAnnotation(for: email)!)?.layer.zPosition = 100
        } else {
            let locationPoint = GroupUserAnnotation()
            locationPoint.coordinate = location
            locationPoint.email = email
            locationPoint.image = Locations.groupUsers.groupUserFrom(email: email)!.profilePicture?.toImage()
            locationPoint.title = email
            
            self.addAnnotation(locationPoint)
        }
    }
    
    func removeGroupMember(email: String) {
        guard annotations.numberOfAnnotations(for: email) > 0 else { return }
        self.removeAnnotation(annotations.getGroupUserAnnotation(for: email)!)
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
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        return self.visibleMapRect.contains(MKMapPoint(coordinate))
    }
    
    func topCenterCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }
    
    func currentRadius() -> Double {
        let centerLocation = CLLocation(latitude: self.centerCoordinate.latitude, longitude: self.centerCoordinate.longitude)
        let topCenterCoordinate = self.topCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        return centerLocation.distance(from: topCenterLocation)
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

extension Array where Element == MKAnnotation {
    func getGroupUserAnnotation(for email: String) -> GroupUserAnnotation? {
        
        var matches: [GroupUserAnnotation] = []
        for annotation in self {
            if (annotation as? GroupUserAnnotation)?.email == email {
                matches.append(annotation as! GroupUserAnnotation)
            }
        }
        return matches.last
    }
    
    func numberOfAnnotations(for email: String) -> Int {
        var count = 0
        
        for annotation in self {
            if (annotation as? GroupUserAnnotation)?.email == email {
                count += 1
            }
        }
        
        return count
    }
}
