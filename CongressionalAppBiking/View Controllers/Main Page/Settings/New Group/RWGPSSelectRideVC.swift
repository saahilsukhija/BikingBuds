//
//  RWGPSSelectRideVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 11/12/22.
//

import UIKit
import FirebaseFunctions
class RWGPSSelectRideVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var routes: [RWGPSRoutePreview] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 75
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = .clear
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        
        
    }
    
    @IBAction func infoButtonClicked(_ sender: Any) {
        //TODO: Show "if your route isnt showing up, save it to "my routes" on the RWGPS website."
        Alert.showDefaultAlert(title: "Don't see your route?", message: "If your route doesn't show up, save it to \"my routes\" on the RWGPS website.", self)
    }
    
    @IBAction func xButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        RWGPSUser.logOut()
        
//        if let vc = presentingViewController as? RWGPSLoginVC {
//            self.dismiss(animated: true)
//            vc.dismiss(animated: false)
//        } else {
//            self.dismiss(animated: true)
//        }
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard RWGPSUser.isLoggedIn(), let _ = RWGPSUser.id else {
            goToLoginScreenRWGPS()
            return
        }
        
        let loadingScreen = createLoadingScreen(frame: view.frame, message: "Getting routes...")
        view.addSubview(loadingScreen)
        
        RWGPSUser.getRoutes { completed, routes, message in
            DispatchQueue.main.async {
                loadingScreen.removeFromSuperview()
                if(!completed) {
                    self.showErrorNotification(message: message!)
                } else {
                    self.routes = routes
                    self.tableView.reloadData()
                    //print(routes)
                }
            }
        }
        
    }

}

extension RWGPSSelectRideVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func requiredHeight(text:String, size: CGFloat, fontName: String) -> CGFloat {
        return text.height(withConstrainedWidth: view.frame.size.width-20, font: UIFont(name: fontName, size: size)!)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) {
            let name = routes[indexPath.row].name
            let description = routes[indexPath.row].description
            
            let required = requiredHeight(text: name, size: 20, fontName: "Poppins-Medium") + requiredHeight(text: description, size: 16, fontName: "Poppins-Regular")
            return required > 90 ? required+30 : 90
        }
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RWGPSRoutePreviewCell.identifier) as! RWGPSRoutePreviewCell
        
        cell.configure(with: routes[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let loadingScreen = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingScreen)
        
        let id = routes[indexPath.row].id
        RWGPSRoute.getRouteDetails(from: id) { error in
            DispatchQueue.main.async {
                loadingScreen.removeFromSuperview()
                if let error = error {
                    self.showErrorNotification(message: error)
                } else {
                    self.showSuccessNotification(message: "Successfully loaded route")
                    self.dismiss(animated: true)
                    NotificationCenter.default.post(name: .rwgpsRouteLoaded, object: nil)
                    
                    if let groupID = Constants.groupID {
                        
                        RealtimeUpload.upload(data: id, path: "rides/\(groupID)/rwgps_route/rwgps_id")
                        
                        Functions.functions().httpsCallable("sendRWGPSRouteUpdate").call(["groupID" : groupID]) { result, error in
                            if let result = result {
                                print("YAYYYYY")
                                print(result.data)
                            } else {
                                print("fuck" + (error?.localizedDescription ?? "(no error)"))
                            }
                        }
                        
                    }
                    else {
                        print("constants groupID not working")
                    }
                    
                   // print(RWGPSRoute.title)
                }
            }
        }
    }
    
    
}
extension RWGPSSelectRideVC {
    func goToLoginScreenRWGPS() {
        if presentingViewController as? RWGPSLoginVC == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "RWGPSLoginScreen") as! RWGPSLoginVC
            self.present(vc, animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}
