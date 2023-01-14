//
//  RWGPSUser.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 11/12/22.
//

import Foundation

struct RWGPSUser {
    static var email: String?
    static var authToken: String?
    static var password: String?
    static var id: String?
    static var routes: [RWGPSRoute] = []
    
    static func authenticate(email: String, password: String, completion: @escaping(Bool, String) -> Void) {
        let request = URL(string: "https://ridewithgps.com/users/current.json?email=\(email)&password=\(password)&apikey=\(Constants.RWGPS_APIKEY)&version=2")!
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let error = error {
                print("error: " + error.localizedDescription)
                completion(false, "Network Error")
            }
            do {
                if let data = data {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    if let token = json["user"]?["auth_token"] as? String {
                        self.authToken = token
                        self.email = email
                        self.password = password
                        UserDefaults.standard.set(email, forKey: "rwgps_email")
                        UserDefaults.standard.set(password, forKey: "rwgps_password")
                        UserDefaults.standard.set(token, forKey: "rwgps_authToken")
                        completion(true, "Successfully Signed In!")
                    }
                    else {
                        completion(false, "Please enter valid credentials")
                    }
                    
                } else {
                    completion(false, "Something went wrong!")
                    
                }
            } catch {
                completion(false, "Something went wrong!")
            }
        })

        task.resume()
    }
    
    static func logOut() {
        email = nil
        password = nil
        authToken = nil
        id = nil
        UserDefaults.standard.removeObject(forKey:  "rwgps_email")
        UserDefaults.standard.removeObject(forKey:  "rwgps_password")
        UserDefaults.standard.removeObject(forKey:  "rwgps_authToken")
        UserDefaults.standard.removeObject(forKey:  "rwgps_id")
    }
    
    static func hasEmailAndPasswordStored() -> Bool {
        return UserDefaults.standard.string(forKey: "rwgps_email") != nil && UserDefaults.standard.string(forKey: "rwgps_password") != nil
    }
    
    static func login(email: String, password: String, completion: @escaping(Bool, String) -> Void) {
        self.authenticate(email: email, password: password) { completed, message in
            if !completed {
                completion(false, message)
            } else {
                RWGPSUser.getID { com, mes in
                    completion(com, mes)
                }
            }
        }
    }
    
    
    ///ONLY WORKS WITH EMAIL AND PASSWORD ALREADY SAVED IN DEVICE
    static func login(completion: @escaping(Bool, String) -> Void) {
        guard let email = UserDefaults.standard.string(forKey: "rwgps_email"), let password = UserDefaults.standard.string(forKey: "rwgps_password") else { completion(false, "Credentials not provided"); return; }
        
        self.email = email
        self.password = password
        self.login(email: email, password: password) { completed, message in
            completion(completed, message)
        }
    }

    static func getID(completion: @escaping(Bool, String) -> Void) {
        guard let token = authToken else {
            completion(false, "Error Signing In... Please login again")
            return
        }
        
        var urlComponents = URLComponents(string: "https://ridewithgps.com/users/current.json")!
        let queryItems = [URLQueryItem(name:"apikey", value:Constants.RWGPS_APIKEY),
                          URLQueryItem(name:"version", value:"2"),
                          URLQueryItem(name:"auth_token", value:token)]
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { completion(false, "Unexpected error, try again"); return }
        let request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    
                    if let id = (json["user"] as? Dictionary<String, AnyObject>)?["id"] {
                            
                        self.id = "\(id)"
                        UserDefaults.standard.set(self.id!, forKey: "rwgps_id")
                        completion(true, self.id!)
                    }
                    else {
                        print(json["user"] as? Dictionary<String, AnyObject> as Any)
                        print((json["user"] as? Dictionary<String, AnyObject>)?["id"] as Any)
                        completion(false, "Something went wrong...")
                    }
                } catch {
                    completion(false, "Network error")
                }
            } else {
                completion(false, "Network error")
            }
        })
        
        

        task.resume()
    }
    
    static func isLoggedIn() -> Bool {
        return authToken != nil
    }
    
    static func getRoutes(completion: @escaping(Bool, [RWGPSRoutePreview], String?) -> Void) {
        guard let token = authToken, let id = id else {
            completion(false, [], "Error Signing In... Please login again")
            return
        }
        
        var urlComponents = URLComponents(string: "https://ridewithgps.com/users/\(id)/routes.json")!
        let queryItems = [URLQueryItem(name:"apikey", value: Constants.RWGPS_APIKEY),
                          URLQueryItem(name:"version", value:"2"),
                          URLQueryItem(name:"auth_token", value:token),
                          URLQueryItem(name:"offset", value: "0"),
                          URLQueryItem(name:"limit", value: "20")
        ]
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { completion(false, [], "Unexpected error, try again"); return }
        let request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    //print(try JSONSerialization.jsonObject(with: data))
                    if let results = (json["results"] as? [Dictionary<String, AnyObject>]) {
                        
                        var routes: [RWGPSRoutePreview] = []
                        for result in results {
                            routes.append(
                                RWGPSRoutePreview(
                                    name: result["name"] as? String ?? "no_name",
                                    description: result["description"] as? String ?? "",
                                    miles: result["distance"] as? Double ?? 0,
                                    elevation: result["elevation_gain"] as? Double ?? 0,
                                    createdAt: RWGPSRoutePreview.convertToDate(result["created_at"] as? String ?? ""),
                                    id: String(result["id"] as? Int ?? 0)))
                        }
                        completion(true, routes, nil)
                    }
                    else {
                        print(json["results"] ?? "")
                        completion(false, [], "Something went wrong...")
                    }
                } catch {
                    print("ugh: \(data)")
                    completion(false, [], "Network error")
                }
            } else {
                completion(false, [], "Network error")
            }
        })
        
        

        task.resume()
    }
    
    
}
