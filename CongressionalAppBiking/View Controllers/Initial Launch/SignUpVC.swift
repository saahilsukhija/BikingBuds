//
//  SignUpVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 11/27/21.
//

import UIKit
import FirebaseAuth

class SignUpVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var loginToExistingAccount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(userProvidedInfo), name: .additionalInfoCompleted, object: nil)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        //Don't have account? Create one!
        let mutableString = NSMutableAttributedString(string: loginToExistingAccount.text!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)])
        mutableString.setColor(color: .accentColor, forText: "Log In")
        loginToExistingAccount.attributedText = mutableString
        loginToExistingAccount.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loginButtonTapped))
        loginToExistingAccount.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, let confirmedPassword = confirmPasswordTextField.text, email != "", password != "", confirmedPassword != "" else {
            showFailureToast(message: "Empty Text Field")
            return
        }
        
        guard password == confirmedPassword else {
            showFailureToast(message: "Passwords do not match.")
            return
        }
        
        guard isValidEmail(email) else {
            showFailureToast(message: "Invalid email")
            return
        }
        
        let loadingScreen = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingScreen)
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                loadingScreen.removeFromSuperview()
                self.showErrorNotification(message: error.localizedDescription)
            } else {
                self.setUpAccount(authResult, loadingScreen: loadingScreen)
            }
        }
    }
    
    func setUpAccount(_ result: AuthDataResult?, loadingScreen: UIView) {
        Authentication.user = result!.user
        
        
        //self.dismiss(animated: true, completion: nil)
        let vc = storyboard!.instantiateViewController(identifier: "additionalInfoScreen") as! AdditionalInfoVC
        vc.modalPresentationStyle = .fullScreen
        
        StorageRetrieve().getPhoneNumbers(from: Authentication.user!) { phoneNumber, emergencyPhoneNumber in
            if let phoneNumber = phoneNumber {
                vc.setPhoneNumberField(phoneNumber)
            }
            if let emergencyPhoneNumber = emergencyPhoneNumber {
                vc.setEmergencyPhoneNumberField(emergencyPhoneNumber)
            }
            
            loadingScreen.removeFromSuperview()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @objc func userProvidedInfo() {
        self.dismiss(animated: true, completion: nil)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func loginButtonTapped() {
        if presentingViewController as? LoginVC != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "loginScreen") as! LoginVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            passwordTextField.becomeFirstResponder()
            break
        case 1:
            confirmPasswordTextField.becomeFirstResponder()
            break
        default:
            textField.resignFirstResponder()
        }
        return false
    }
}
