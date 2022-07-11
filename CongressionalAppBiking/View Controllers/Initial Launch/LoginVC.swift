//
//  SignUpVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/8/21.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import AuthenticationServices
import CryptoKit
class LoginVC: UIViewController {
    
    
    @IBOutlet weak var loginWithGoogleButton: RoundedButton!
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var signInWithAppleButton: RoundedButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var loginType: LogInType!
    var currentUser: User!
    var appleName: String?
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        //Google Sign In
        loginWithGoogleButton.layer.borderColor = UIColor.systemGray2.cgColor
        loginWithGoogleButton.layer.borderWidth = 1
        
        signInWithAppleButton.layer.borderColor = UIColor.systemGray2.cgColor
        signInWithAppleButton.layer.borderWidth = 1
        
        //Don't have account? Create one!
        let mutableString = NSMutableAttributedString(string: createAccountLabel.text!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)])
        mutableString.setColor(color: .accentColor, forText: "Sign Up")
        createAccountLabel.attributedText = mutableString
        createAccountLabel.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signUpButtonTapped))
        createAccountLabel.addGestureRecognizer(gestureRecognizer)
        
        //Know when user has signed in successfully
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignInWithGoogle), name: .signInGoogleCompleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userProvidedInfo), name: .additionalInfoCompleted, object: nil)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func setUpAccount(_ result: AuthDataResult?, loadingScreen: UIView) {
        Authentication.user = result!.user
        currentUser = Authentication.user
        
        if let appleName = appleName {
            let changeRequest = currentUser.createProfileChangeRequest() // (3)
            changeRequest.displayName = appleName
            changeRequest.commitChanges { [self] error in
                if let error = error {
                    showFailureToast(message: error.localizedDescription)
                } else {
                    let vc = storyboard!.instantiateViewController(identifier: "additionalInfoScreen") as! AdditionalInfoVC
                    vc.modalPresentationStyle = .fullScreen
                    
                    StorageRetrieve().getPhoneNumbers(from: currentUser) { phoneNumber, emergencyPhoneNumber in
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
            }
        } else {
            let vc = storyboard!.instantiateViewController(identifier: "additionalInfoScreen") as! AdditionalInfoVC
            vc.modalPresentationStyle = .fullScreen
            
            StorageRetrieve().getPhoneNumbers(from: currentUser) { phoneNumber, emergencyPhoneNumber in
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
    }
    
    @objc func userProvidedInfo() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().presentingViewController = self
        loginType = .google
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func appleButtonTapped(_ sender: Any) {
        startSignInWithAppleFlow()
    }
    
    @IBAction func emailButtonTapped(_ sender: Any) {
        loginWithEmailAndPassword()
    }
    
    @objc func signUpButtonTapped() {
        if presentingViewController as? SignUpVC != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "signUpScreen") as! SignUpVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
}

//MARK: -Email Sign In
extension LoginVC {
    func loginWithEmailAndPassword() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { showFailureToast(message: "Empty Textfield"); return }
        guard isValidEmail(email) else { showFailureToast(message: "Invalid email. Check and try again."); return }
        
        let loadingScreen = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingScreen)
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                loadingScreen.removeFromSuperview()
                self.showFailureToast(message: "Account does not exist.")
            } else {
                self.setUpAccount(result, loadingScreen: loadingScreen)
            }
        }
        
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
//MARK: -Google Sign In
extension LoginVC: GIDSignInDelegate {
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
extension LoginVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
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
        loginType = .apple
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
            
            if let first = appleIDCredential.fullName?.givenName, let last = appleIDCredential.fullName?.familyName {
                appleName = first + " " + last
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
        } else { print("oh no")}
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    
}

extension LoginVC: UITextFieldDelegate {
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


enum LogInType: String {
    case google = "Google"
    case email = "Email"
    case apple = "Apple"
}
