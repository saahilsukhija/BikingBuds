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
        addTableViewHeader()
        tableView.backgroundColor = .clear
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        hideKeyboardWhenTappedAround()
        
        
        
    }
    
    func addTableViewHeader() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 100))
        
        let enterLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width / 2 - 10, height: 20))
        enterLabel.text = "Enter RWGPS URL:"
        enterLabel.font = UIFont(name: "Poppins-Medium", size: 14)
        
        let urlTextField = UITextField(frame: CGRect(x: 10, y: 32, width: view.frame.size.width - 20, height: 50))
        urlTextField.placeholder = "https://ridewithgps.com/routes/0000000"
        urlTextField.font = UIFont(name: "Poppins-Medium", size: 14)
        urlTextField.layer.borderWidth = 1.2
        urlTextField.layer.borderColor = UIColor.black.cgColor
        urlTextField.setLeftPaddingPoints(10)
        urlTextField.returnKeyType = .done
        urlTextField.delegate = self
 
        header.addSubview(enterLabel)
        header.addSubview(urlTextField)
        
        header.addBottomBorder(with: .black, andWidth: 1)
        tableView.tableHeaderView = header
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
                    self.showFailureToast(message: message!)
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
            
            let required = requiredHeight(text: name, size: 20, fontName: "Poppins-Medium") + requiredHeight(text: "1/3/22", size: 15, fontName: "Poppins-Light")
            return required + 20
        }
        return 80
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
        connectRWGPSRoute(with: id, loadingScreen)
    }
    
    func connectRWGPSRoute(with id: String, _ loadingScreen: UIView?) {
        RWGPSRoute.getRouteDetails(from: id) { error in
            DispatchQueue.main.async {
                loadingScreen?.removeFromSuperview()
                if let error = error {
                    self.showFailureToast(message: error)
                } else {
                    self.showSuccessToast(message: "Successfully loaded route")
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
                }
            }
        }
    }
    
}

extension RWGPSSelectRideVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submitURL(textField)
        
        return true
    }

    func submitURL(_ textField: UITextField) {
        guard let text = textField.text, text.count > 0 else {
            self.showFailureToast(message: "Invalid URL")
            return
        }
        
        guard let id = text.split(separator: "/").last else {
            self.showFailureToast(message: "Invalid RWGPS URL")
            return
        }
        
        let loadingScreen = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingScreen)
        
        connectRWGPSRoute(with: String(id), loadingScreen)
        
        
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
