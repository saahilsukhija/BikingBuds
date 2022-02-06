//
//  SignUpVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 11/27/21.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit
class SignUpVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginToExistingAccount: UILabel!
    
    @IBOutlet weak var signInWithAppleButton: RoundedButton!
    @IBOutlet weak var loginWithGoogleButton: RoundedButton!
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(userProvidedInfo), name: .additionalInfoCompleted, object: nil)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginWithGoogleButton.layer.borderColor = UIColor.systemGray2.cgColor
        loginWithGoogleButton.layer.borderWidth = 1
        
        signInWithAppleButton.layer.borderColor = UIColor.systemGray2.cgColor
        signInWithAppleButton.layer.borderWidth = 1
        
        //Don't have account? Create one!
        let mutableString = NSMutableAttributedString(string: loginToExistingAccount.text!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)])
        mutableString.setColor(color: .accentColor, forText: "Log In")
        loginToExistingAccount.attributedText = mutableString
        loginToExistingAccount.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loginButtonTapped))
        loginToExistingAccount.addGestureRecognizer(gestureRecognizer)
        
        //Know when user has signed in successfully
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignInWithGoogle), name: .signInGoogleCompleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userProvidedInfo), name: .additionalInfoCompleted, object: nil)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            showFailureToast(message: "Empty Text Field")
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
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func appleButtonTapped(_ sender: Any) {
        startSignInWithAppleFlow()
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            passwordTextField.becomeFirstResponder()
            break
        default:
            textField.resignFirstResponder()
        }
        return false
    }
}

//MARK: -Google Sign In
extension SignUpVC: GIDSignInDelegate {
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
                setUpAccount(result, loadingScreen: loadingScreen)
            }
        }
    }
    
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

//MARK: -Custom Apple Button + Auth with Firebase
extension SignUpVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let loadingScreen = createLoadingScreen(frame: view.frame)
            view.addSubview(loadingScreen)
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                else {
                    self.setUpAccount(authResult, loadingScreen: loadingScreen)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    
}
