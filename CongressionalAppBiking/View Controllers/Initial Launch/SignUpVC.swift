//
//  SignUpVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/8/21.
//

import UIKit
import GoogleSignIn

class SignUpVC: UIViewController {

    @IBOutlet weak var googleSignIn: GIDSignInButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleSignIn.colorScheme = (overrideUserInterfaceStyle == .light) ? .dark : .light
        googleSignIn.style = .wide
        GIDSignIn.sharedInstance().presentingViewController = self
        
        //Know when user has signed in successfully
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignIn), name: .signInGoogleCompleted, object: nil)
    }
    
    @objc func userDidSignIn() {
        User.setUpUser(GIDSignIn.sharedInstance().currentUser)
        showAnimationToast(animationName: "LoginSuccess", message: "Welcome, " + User.firstName, color: .systemBlue, fontColor: .systemBlue)
        self.dismiss(animated: true, completion: nil)
    }
    

}
