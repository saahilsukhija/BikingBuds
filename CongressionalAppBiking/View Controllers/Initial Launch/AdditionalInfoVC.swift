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

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emergencyPhoneNumberTextField: UITextField!
    @IBOutlet weak var pictureChangeView: UIView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var currentlyLoggedIn: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var currentUser: User!
    var imageChanged = false
    var anythingChanged = false
    var phoneNumber: String!
    var emergencyPhoneNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.addDoneButtonOnKeyboard()
        
        //Differentiate between textfields for delegate
        firstNameTextField.tag = 0
        lastNameTextField.tag = 1
        phoneNumberTextField.tag = 2
        emergencyPhoneNumberTextField.tag = 3
        
        firstNameTextField.returnKeyType = .next
        lastNameTextField.returnKeyType = .next
        phoneNumberTextField.returnKeyType = .next
        emergencyPhoneNumberTextField.returnKeyType = .done
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        phoneNumberTextField.delegate = self
        emergencyPhoneNumberTextField.delegate = self
        
//        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        emergencyPhoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        firstNameTextField.addTarget(self, action: #selector(nameFieldDidChange(_:)), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(nameFieldDidChange(_:)), for: .editingChanged)
        
        //Round view
        pictureChangeView.layer.cornerRadius = 10
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageChoice(_:)))
        pictureChangeView.addGestureRecognizer(tapGesture)
        
        //Round image view
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2
        profilePictureImageView.layer.borderWidth = 1
        profilePictureImageView.layer.borderColor = UIColor.black.cgColor
        
        StorageRetrieve().setProfilePicture(for: profilePictureImageView, email: Auth.auth().currentUser!.email!)
        
        currentlyLoggedIn.isUserInteractionEnabled = true
        currentlyLoggedIn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchAccountsButtonClicked)))
        
        if navigationController != nil {
            self.configureNavBar()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Authentication.hasPreviousSignIn() {
            currentUser = Auth.auth().currentUser
            print(currentUser.displayName ?? "has no display name")
            print(Auth.auth().currentUser?.email ?? "has no email")
            let name = currentUser.displayName?.components(separatedBy: " ")
            if let first = name?.first {
                firstNameTextField.text = first
            }
            if name?.count ?? 0 > 1 {
                lastNameTextField.text = name?[1]
            }
            
            if phoneNumber == "" || phoneNumber == nil {
                phoneNumberTextField.text = Authentication.phoneNumber
            } else {
                phoneNumberTextField.text = phoneNumber
            }
            if emergencyPhoneNumber == "" || emergencyPhoneNumber == nil {
                emergencyPhoneNumberTextField.text = Authentication.emergencyPhoneNumber
            } else {
                emergencyPhoneNumberTextField.text = emergencyPhoneNumber
            }
            
            //Not _____? Switch Accounts.
            let mutableString = NSMutableAttributedString(string: "Not \(currentUser.displayName ?? (currentUser.email) ?? "this person")? Switch Accounts.", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
            mutableString.setColor(color: .accentColor, forText: "Switch Accounts.")
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
        
        guard firstNameTextField.text != "" && lastNameTextField.text != "" && phoneNumberTextField.text != "" else {
            self.showFailureToast(message: "Empty TextField")
            return
        }

        
        guard anythingChanged else {
            if self.navigationController != nil {
                self.navigationController?.popViewController(animated: true)
                Authentication.user = Auth.auth().currentUser
                NotificationCenter.default.post(name: .additionalInfoCompleted, object: nil)
            } else {
                self.dismiss(animated: true) {
                    Authentication.user = Auth.auth().currentUser
                    NotificationCenter.default.post(name: .additionalInfoCompleted, object: nil)
                }
            }
            
            return
        }
        
        let loadingScreen = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingScreen)
        
        Authentication.phoneNumber = phoneNumber
        Authentication.emergencyPhoneNumber = emergencyPhoneNumber
        
        let currentUserEditor = currentUser.createProfileChangeRequest()
        currentUserEditor.displayName = (firstNameTextField.text ?? "") + " " + (lastNameTextField.text ?? "")
        
        currentUserEditor.commitChanges { [self] error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            showAnimationToast(animationName: "LoginSuccess", message: "Welcome, \(currentUser.displayName!)")
            
            var potentialImage: UIImage?
            if imageChanged {
                potentialImage = image
            } else {
                potentialImage = nil
            }
            StorageUpload().uploadCurrentUser(currentUser, phoneNumber: phoneNumberTextField.text!, emergencyPhoneNumber: emergencyPhoneNumberTextField.text!, image: potentialImage) { completed in
                loadingScreen.removeFromSuperview()
                
                if completed {
                    if self.navigationController != nil {
                        self.navigationController?.popViewController(animated: true)
                        Authentication.user = Auth.auth().currentUser
                        NotificationCenter.default.post(name: .additionalInfoCompleted, object: nil)
                    } else {
                        self.dismiss(animated: true) {
                            Authentication.user = Auth.auth().currentUser
                            NotificationCenter.default.post(name: .additionalInfoCompleted, object: nil)
                        }
                    }
                } else {
                    self.showFailureToast(message: "Something went wrong...")
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
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func configureNavBar() {
        let xButton = UIBarButtonItem(image: UIImage(named: "multiply"), style: .done, target: self, action: #selector(dismissNavSelf))
        xButton.tintColor = .label
        navigationItem.leftBarButtonItem = xButton
        
        //titleLabel.addConstraint(NSLayoutConstraint(item: navigationItem, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 10))
        
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    @objc func dismissNavSelf() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Authentication.phoneNumber = phoneNumberTextField.text
        Authentication.emergencyPhoneNumber = emergencyPhoneNumberTextField.text
    }
}

//MARK: -Image Pickers
extension AdditionalInfoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imageChoice(_ sender: UIView) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.imageChanged = true
            self.anythingChanged = true
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.imageChanged = true
            self.anythingChanged = true
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
            lastNameTextField.becomeFirstResponder()
        } else if textField.tag == 1 {
            //Is phone number
            phoneNumberTextField.becomeFirstResponder()
            
        } else if textField.tag == 2 {
            emergencyPhoneNumberTextField.becomeFirstResponder()
        } else if textField.tag == 3 {
            view.endEditing(true)
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        anythingChanged = true
        if (textField == phoneNumberTextField || textField == emergencyPhoneNumberTextField) {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: NSCharacterSet.decimalDigits.inverted)

            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.hasPrefix("1")

            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int

                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()

            if hasLeadingOne {
                formattedString.append("+1 ")
                index += 1
            }
            if (length - index) > 3 {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }

            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false
        }
        else {
            return true
        }
    }
    //Reformat phone number text field to show proper phone number
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        if textField.text!.count == 17 {
//            view.endEditing(true)
//        }
//
//        textField.text = format(with: "+X (XXX) XXX-XXXX", phone: textField.text!)
//
//        anythingChanged = true
//    }
    
    @objc func nameFieldDidChange(_ textField: UITextField) {
        anythingChanged = true
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
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        emergencyPhoneNumberTextField.inputAccessoryView = doneToolbar
        phoneNumberTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        emergencyPhoneNumberTextField.resignFirstResponder()
        phoneNumberTextField.resignFirstResponder()
        
    }
}
