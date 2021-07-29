//
//  JoinGroupVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/8/21.
//

import UIKit
import GoogleSignIn
import FirebaseDatabase

class JoinGroupVC: UIViewController {

    @IBOutlet weak var soloButton: RoundedButton!
    @IBOutlet weak var groupButton: RoundedButton!
    @IBOutlet weak var groupDetailsEnterView: UIView!
    
    var rideType: RideType!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.showLoggedIn()
        self.hideKeyboardWhenTappedAround()
        
        groupDetailsEnterView.isHidden = true
    }
    
    @IBAction func goToMainPage(_ sender: Any) {
        
        guard let rideType = rideType else {
            Alert.showDefaultAlert(title: "No Ride Type Selected", message: "Before continuing, you must select if you are riding solo or in a group", self)
            return
        }
        
        let loadingScreen = createLoadingScreen(frame: view.frame, message: "Initializing...")
        self.view.addSubview(loadingScreen)
        
        //Go to Next Page
        let storyboard = UIStoryboard(name: "MainPage", bundle: nil)
        var goToVC: BikingVCs!
        
        //Change the presenting view controller to solo or group, depending on user input
        //TODO: -Still Complete
        goToVC = (rideType == .group) ? storyboard.instantiateViewController(identifier: "bikingGroupScreen") as! BikingGroupVC : storyboard.instantiateViewController(identifier: "bikingGroupScreen") as! BikingGroupVC
        goToVC.rideType = rideType
        
        let navigationController = UINavigationController(rootViewController: goToVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func soloButtonClicked(_ sender: Any) {
        //Unselect Group Button
        if rideType != .solo {
            groupButton.backgroundColor = UIColor(named: "unselectedGrayColor")
            groupDetailsEnterView.isHidden = true
        }
        
        soloButton.backgroundColor = UIColor(named: "selectedBlueColor")
        rideType = .solo
    }
    
    @IBAction func groupButtonClicked(_ sender: Any) {
        //Unselect Solo Button
        if rideType != .group {
            soloButton.backgroundColor = UIColor(named: "unselectedGrayColor")
            groupDetailsEnterView.isHidden = false
        }
        
        groupButton.backgroundColor = UIColor(named: "selectedBlueColor")
        rideType = .group
    }
    
    @IBAction func createGroupClicked(_ sender: Any) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkFirstLaunch()
    }
    
    //Show Toast Saying "Welcome, (user)"
    func showLoggedIn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.userIsLoggedIn() {
                //Set Up User Object
                User.setUpUser(GIDSignIn.sharedInstance().currentUser)
                
                self.showAnimationToast(animationName: "LoginSuccess", message: "Welcome, " + User.firstName, color: .systemBlue, fontColor: .systemBlue)
                
                StorageUpload().uploadUserObject()
            }
        }
    }

}

//MARK: Initial Launch
extension JoinGroupVC {
    func checkFirstLaunch() {
        //Track if this is the first launch
        let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunched")
        
        if !hasLaunched {
            UserDefaults.standard.setValue(true, forKey: "hasLaunched")
            
            //Initialize signup screen
            let storyboard = UIStoryboard(name: "InitialLaunch", bundle: nil)
            let signUpScreen = storyboard.instantiateViewController(withIdentifier: "signUp") as! SignUpVC
            signUpScreen.modalPresentationStyle = .fullScreen
            
            self.present(signUpScreen, animated: true, completion: nil)
        }
    }
}

enum RideType {
    case solo
    case group
}
