//
//  RWGPSLoginVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 11/12/22.
//

import UIKit

class RWGPSLoginVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var eyeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eyeButton.setTitle("", for: .normal)
        emailTextField.font = UIFont(name: "Montserrat-Regular", size: 16)
        passwordTextField.font = UIFont(name: "Montserrat-Regular", size: 16)
        
        emailTextField.tag = 0
        passwordTextField.tag = 1
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        eyeButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
    }
    
    
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            self.showFailureToast(message: "Empty Text Field")
            return
        }
        
        guard isValidEmail(email) else {
            self.showFailureToast(message: "Please provide a valid email")
            return
        }
        
        let loadingScreen = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingScreen)
        RWGPSUser.login(email: email, password: password) { completed, message in
            DispatchQueue.main.async {
                
                if(!completed) {
                    self.showFailureToast(message: message)
                    loadingScreen.removeFromSuperview()
                } else {
                    NotificationCenter.default.post(name: .rwgpsUserLogin, object: nil)
                    //go to other vc
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        loadingScreen.removeFromSuperview()
                        if !RWGPSRoute.connected {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RWGPSSelectRideScreen") as! RWGPSSelectRideVC
                            self.present(vc, animated: true)

                        } else {
                            self.showSuccessToast(message: "Successfully logged in")
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    //self.dismiss(animated: true)
                }
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func eyeButtonClicked(_ sender: UIButton) {
        
        if eyeButton.image(for: .normal) == UIImage(systemName: "eye.fill") {
            eyeButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
            passwordTextField.isSecureTextEntry = false
        } else {
            eyeButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            passwordTextField.isSecureTextEntry = true
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RWGPSLoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            passwordTextField.becomeFirstResponder()
        }
        else if textField.tag == 1 {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
