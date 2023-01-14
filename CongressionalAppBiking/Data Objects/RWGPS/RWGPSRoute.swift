//
//  Route.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 11/19/22.
//

import Foundation
import CoreLocation
import FirebaseDatabase
struct RWGPSRoute {
    
    static var title: String!
    static var description: String!
    
    static  var start: CLLocationCoordinate2D!
    static var end: CLLocationCoordinate2D!
    
    static var poi: [RWGPSPOI] = []
    static var last_updated: Date!
    
    static var connected: Bool! = false
    
    static func addNotificationsForRouteUpdate(for group: String) {
        let ref = Database.database().reference().child("rides/" + group + "/rwgps_route")
        
        ref.observe(.value) { snap in
            guard snap.children.allObjects.count > 0 else { return }
            guard let snapDict = snap.value as? Dictionary<String, String> else {
                print(snap.key);
                print(snap.value as Any)
                print((snap.children.allObjects[0] as? DataSnapshot)?.value as Any)
                return
            }
            
            guard let id = snapDict["rwgps_id"] else {
                print(snapDict.values as Any)
                return
            }
            
            print("rwgps route update observed")
            NotificationCenter.default.post(name: .rwgpsUpdatedInGroup, object: nil, userInfo: ["id" : id])
        }
    }
    
    
    static func getRouteDetails(from id: String, completion: @escaping(String?) -> Void) {
        guard let token = RWGPSUser.authToken else {
            completion("Error Signing In... Please login again")
            return
        }
        
        var urlComponents = URLComponents(string: "https://ridewithgps.com/routes/\(id).json")!
        let queryItems = [URLQueryItem(name:"apikey", value: Constants.RWGPS_APIKEY),
                          URLQueryItem(name:"version", value:"2"),
                          URLQueryItem(name:"auth_token", value:token),
                          URLQueryItem(name:"offset", value: "0"),
                          URLQueryItem(name:"limit", value: "20")
        ]
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { completion("Unexpected error, try again"); return }
        let request = URLRequest(url: url)

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    //print(try JSONSerialization.jsonObject(with: data))
                    if let route = json["route"] as? Dictionary<String, AnyObject> {
                        
                        if
                        let title = route["name"] as? String,
                        let description = route["description"] as? String,
                        let startingLat = route["first_lat"] as? Double,
                        let startingLong = route["first_lng"] as? Double,
                        let endingLat = route["last_lat"] as? Double,
                        let endingLong = route["last_lng"] as? Double,
                        let trackPoints = route["track_points"] as? [Dictionary<String, AnyObject>]
                        {
                            var points: [RWGPSPOI] = []
                            for result in trackPoints {
                                points.append(RWGPSPOI(lat: result["y"] as? Double, long: result["x"] as? Double, distance: result["d"] as? Double, elevation: result["e"] as? Double))
                            }
                            
                            self.title = title
                            self.description = description
                            self.start = CLLocationCoordinate2D(latitude: startingLat, longitude: startingLong)
                            self.end = CLLocationCoordinate2D(latitude: endingLat, longitude: endingLong)
                            self.poi = points
                            self.last_updated = Date() //TODO: Fix later
                            self.connected = true
                            completion(nil)
                        } else {
                            completion("Something went wrong...")
                        }
                        
                        
                    }
                    else {
                        print(json["results"] ?? "")
                        completion("Something went wrong...")
                    }
                } catch {
                    print("ugh: \(data)")
                    completion("Network error")
                }
            } else {
                completion("Network error")
            }
        })
        
        

        task.resume()
    }
}

struct RWGPSPOI {
    var coord: CLLocationCoordinate2D!
    var distance: Double!
    var elevation: Double!
    
    init(lat: Double!, long: Double!, distance: Double!, elevation: Double!) {
        coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.distance = distance
        self.elevation = elevation
    }
}
