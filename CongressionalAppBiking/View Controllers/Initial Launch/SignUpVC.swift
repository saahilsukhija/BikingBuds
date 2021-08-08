//
//  SignUpVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/8/21.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
class SignUpVC: UIViewController {
    

    @IBOutlet weak var loginWithGoogleButton: RoundedButton!
    @IBOutlet weak var createAccountLabel: UILabel!
    
    var loginType: LogInType!
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        //Google Sign In
        GIDSignIn.sharedInstance().presentingViewController = self
        loginWithGoogleButton.layer.borderColor = UIColor.systemGray2.cgColor
        loginWithGoogleButton.layer.borderWidth = 1
        
        //Don't have account? Create one!
        let mutableString = NSMutableAttributedString(string: createAccountLabel.text!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)])
        mutableString.setColor(color: .accentColor, forText: "Sign Up")
        createAccountLabel.attributedText = mutableString
        
        //Know when user has signed in successfully
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignInWithGoogle), name: .signInGoogleCompleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userProvidedInfo), name: .additionalInfoCompleted, object: nil)
    }
    
    @objc func userDidSignInWithGoogle() {
        let loadingScreen = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingScreen)
        guard let authentication = GIDSignIn.sharedInstance().currentUser?.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                          accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { [self] result, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                Authentication.user = result!.user
                currentUser = Authentication.user
 
                
                //self.dismiss(animated: true, completion: nil)
                let vc = storyboard!.instantiateViewController(identifier: "additionalInfoScreen") as! AdditionalInfoVC
                vc.modalPresentationStyle = .fullScreen
                
                StorageRetrieve().getPhoneNumber(from: currentUser) { phoneNumber in
                    vc.setPhoneNumberField(phoneNumber)
                    loadingScreen.removeFromSuperview()
                    present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func userProvidedInfo() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        loginType = .google
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
}

//MARK: -Custom Sign In Button
extension SignUpVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        guard error == nil else {
            print(error.localizedDescription)
            return
        }
        
        userDidSignInWithGoogle()
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
}

enum LogInType: String {
    case google = "Google"
    case email = "Email"
}
