//
//  AdditionalInfoVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/5/21.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
class AdditionalInfoVC: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emergencyPhoneNumberTextField: UITextField!
    @IBOutlet weak var pictureChangeView: UIView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var currentlyLoggedIn: UILabel!
    
    var currentUser: User!
    
    var phoneNumber: String!
    var emergencyPhoneNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        //Differentiate between textfields for delegate
        nameTextField.tag = 0
        phoneNumberTextField.tag = 1
        emergencyPhoneNumberTextField.tag = 2
        
        nameTextField.returnKeyType = .next
        phoneNumberTextField.returnKeyType = .next
        emergencyPhoneNumberTextField.returnKeyType = .done
        
        nameTextField.delegate = self
        phoneNumberTextField.delegate = self
        emergencyPhoneNumberTextField.delegate = self
        
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emergencyPhoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        //Round view
        pictureChangeView.layer.cornerRadius = 10
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageChoice(_:)))
        pictureChangeView.addGestureRecognizer(tapGesture)
        
        //Round image view
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2
        profilePictureImageView.layer.borderWidth = 1
        profilePictureImageView.layer.borderColor = UIColor.label.cgColor
        
        StorageRetrieve().setProfilePicture(for: profilePictureImageView, email: Auth.auth().currentUser!.email!)
        
        currentlyLoggedIn.isUserInteractionEnabled = true
        currentlyLoggedIn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchAccountsButtonClicked)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Authentication.hasPreviousSignIn() {
            currentUser = Auth.auth().currentUser
            nameTextField.text = currentUser.displayName
            phoneNumberTextField.text = phoneNumber
            emergencyPhoneNumberTextField.text = emergencyPhoneNumber
            //Not _____? Switch Accounts.
            let mutableString = NSMutableAttributedString(string: "Not \(currentUser.email!)? Switch Accounts.", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
            mutableString.setColor(color: .accentColor, forText: "Switch Accounts.")
            mutableString.addUnderline(forText: currentUser.email!)
            currentlyLoggedIn.attributedText = mutableString
            
            //Profile Picture
            //StorageRetrieve().setProfilePicture(for: profilePictureImageView, email: currentUser.email!)
        }
        else {
            showFailureToast(message: "Something went wrong logging in. Try Again.")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setPhoneNumberField(_ phone: String) {
        self.phoneNumber = phone
    }
    
    func setEmergencyPhoneNumberField(_ phone: String) {
        self.emergencyPhoneNumber = phone
    }
    
    @IBAction func completedButtonTapped(_ sender: Any) {
        currentUser = Authentication.user
        guard let image = profilePictureImageView.image else {
            self.showFailureToast(message: "No Profile Picture Chosen.")
            return
        }
        
        guard nameTextField.text != "" && phoneNumberTextField.text != "" else {
            self.showFailureToast(message: "Empty TextField")
            return
        }

        let loadingScreen = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingScreen)
        
        Authentication.phoneNumber = phoneNumber
        
        
        let currentUserEditor = currentUser.createProfileChangeRequest()
        currentUserEditor.displayName = nameTextField.text!
        
        currentUserEditor.commitChanges { [self] error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            showAnimationToast(animationName: "LoginSuccess", message: "Welcome, \(currentUser.displayName!)")
            StorageUpload().uploadCurrentUser(currentUser, phoneNumber: phoneNumberTextField.text!, emergencyPhoneNumber: emergencyPhoneNumberTextField.text!, image: image) { completed in
                loadingScreen.removeFromSuperview()
                
                if completed {
                    dismiss(animated: true) {
                        Authentication.user = Auth.auth().currentUser
                        NotificationCenter.default.post(name: .additionalInfoCompleted, object: nil)
                    }
                } else {
                    showFailureToast(message: "Something went wrong...")
                }
            }
            
        }
        
    }
    
    @objc func switchAccountsButtonClicked() {
        if Authentication.hasPreviousSignIn() {
            do {
                try Auth.auth().signOut()
                GIDSignIn.sharedInstance().signOut()
            } catch {}
        }
        if let joinGroupVC = presentingViewController as? JoinGroupVC {
            dismiss(animated: true, completion: nil)
            
            let storyboard = UIStoryboard(name: "InitialLaunch", bundle: nil)
            let signUpScreen = storyboard.instantiateViewController(withIdentifier: "loginScreen") as! LoginVC
            signUpScreen.modalPresentationStyle = .fullScreen
            joinGroupVC.present(signUpScreen, animated: true, completion: nil)
        } else {
            //LoginVC
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: -Image Pickers
extension AdditionalInfoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imageChoice(_ sender: UIView) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func openCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func openGallery() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[.editedImage] as! UIImage
        profilePictureImageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:  true, completion: nil)
    }
    
    
}

//MARK: -Textfield Functions
extension AdditionalInfoVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            //Is name enter
            phoneNumberTextField.becomeFirstResponder()
        } else if textField.tag == 1 {
            //Is phone number
            emergencyPhoneNumberTextField.becomeFirstResponder()
            
        } else if textField.tag == 2 {
            view.endEditing(true)
        }
        return false
    }
    
    //Reformat phone number text field to show proper phone number
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text!.count == 14 {
            view.endEditing(true)
        }
        textField.text = format(with: "(XXX) XXX-XXXX", phone: textField.text!)
    }
    
    /// mask example: `+X (XXX) XXX-XXXX`
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
}
