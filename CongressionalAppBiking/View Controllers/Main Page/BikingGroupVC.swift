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
    var groupName: String!
    var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingView)
        
        super.setUp(map: mapView, rideType: .group)
        self.addGroupCodeToNavController()
        
        mapView.delegate = self
        mapView.register(GroupUserAnnotationView.self, forAnnotationViewWithReuseIdentifier: "groupUser")
        mapView.showsUserLocation = false
        
        navigationController?.navigationItem.title = groupName
        navigationController?.title = groupName
        
        Locations.addNotifications(for: groupID)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .locationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationsUpdated), name: .groupUsersUpdated, object: nil)
        
        loadingView.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let userLocation = locationManager.location {
            uploadUserLocation(userLocation.coordinate)
        }
    }
    
    func addGroupCodeToNavController() {
        let groupCodeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width / 2, height: navigationController?.navigationBar.frame.size.height ?? 75))
        groupCodeLabel.font = UIFont(name: "Singhala Simhan MN", size: 16)
        groupCodeLabel.text = groupName
        groupCodeLabel.textColor = .black
        groupCodeLabel.textAlignment = .center
        
        groupCodeLabel.layer.cornerRadius = groupCodeLabel.frame.size.height / 2
        groupCodeLabel.dropShadow()
        //groupCodeLabel.layer.borderWidth = 1
        //groupCodeLabel.layer.borderColor = UIColor.black.cgColor
        
        groupCodeLabel.layer.backgroundColor = UIColor.white.cgColor
        
        navigationItem.titleView = groupCodeLabel
    }
    
    deinit {
        Locations.removeNotifications(for: groupID)
    }
    
    @objc func userLocationsUpdated() {
        ((bottomSheet.contentViewController as? UINavigationController)?.viewControllers[0] as? BottomSheetInfoGroupVC)!.reloadGroupUsers()
        mapView.drawAllGroupMembers(includingSelf: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0].coordinate.roundTo(places: Preferences.coordinateRoundTo)
        let (latitude, longitude) = (location.latitude, location.longitude)
        
        if previousLatitude != latitude || previousLongitude != longitude {
            uploadUserLocation(location)
            print("previousCoordinate = \(previousLatitude ?? 0), \(previousLongitude ?? 0)")
            print("nowCoordinate = \(latitude), \(longitude)")
        } else {
            //Same Location, not uploading to cloud
        }
        
        super.updatePreviousLocations(location)
    }
    
    func uploadUserLocation(_ location: CLLocationCoordinate2D) {
        UserLocationsUpload.uploadCurrentLocation(group: groupID, location: location) { completed, message in
            if !completed {
                print(message!)
            }
        }
    }
    
    
}

extension BikingGroupVC {

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        var annotationView: MKAnnotationView!
        var annotationIdentifier: String!
        
        if annotation.isKind(of: GroupUserAnnotation.self) {
            annotationIdentifier = "groupUser"
            annotationView = GroupUserAnnotationView(annotation: annotation as! GroupUserAnnotation, reuseIdentifier: annotationIdentifier)
            annotationView.frame = (annotationView as! GroupUserAnnotationView).containerView.frame
    
        } else {
            annotationIdentifier = "marker"
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("selectedAnnotation")
        guard let annotationView = view as? GroupUserAnnotationView else { return }
        guard let bottomSheetVC = (bottomSheet.contentViewController as? UINavigationController)?.viewControllers[0] as? BottomSheetInfoGroupVC else { return }
        guard annotationView.inSelectedState == false else { return }
        
        (bottomSheet.contentViewController as? UINavigationController)?.popToRootViewController(animated: true)
        let groupUser = bottomSheetVC.groupUsers.groupUserFrom(email: (annotationView.annotation as! GroupUserAnnotation).email)!
        let indexPath = IndexPath(row: bottomSheetVC.groupUsers.firstIndex(of: groupUser)!, section: 0)
        bottomSheetVC.tableView(bottomSheetVC.tableView, didSelectRowAt: indexPath)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("deselectedAnnotation")
        guard let annotationView = view as? GroupUserAnnotationView else { return }
        guard annotationView.inSelectedState == false else { return }
        
        (bottomSheet.contentViewController as? UINavigationController)?.popToRootViewController(animated: true)
    }
    
    func makeMapAnnotation(_ annotationChangeType: AnnotationChangeType, for groupUser: GroupUser) {
        guard let groupUserAnnotation = mapView.annotations.getGroupUserAnnotation(for: groupUser.email) else { return }
        
        guard let groupUserAnnotationView = mapView.view(for: groupUserAnnotation) as? GroupUserAnnotationView else { return }
    
        if annotationChangeType == .bigger {
            groupUserAnnotationView.makeAnnotationSelected()
        } else {
            groupUserAnnotationView.makeAnnotationDeselected()
        }
        
        mapView.drawGroupMember(email: groupUser.email, location: groupUserAnnotation.coordinate)
        
    }
}
