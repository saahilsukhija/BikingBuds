//
//  MessagesVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 6/16/22.
//

import UIKit
import FirebaseFunctions

class AnnouncementVC: UIViewController {
    
//    @IBOutlet var quickTypeButtons: [UIButton]!
    @IBOutlet var announcementTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    
    var announcement: String?
    var group: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
//        for button in quickTypeButtons {
//            button.layer.cornerRadius = button.frame.size.height / 2
//            button.layer.borderColor = UIColor.systemGray.cgColor
//            button.layer.borderWidth = 1
//        }
        announcementTextField.text = announcement
        announcementTextField.delegate = self
        textDidEdit(announcementTextField as Any)
    }
    
    func setAnnouncement(_ announcement: String) {
        self.announcement = announcement
        print("set")
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func textDidEdit(_ sender: Any) {
        if announcementTextField.text?.count ?? 0 > 0 {
            let titleAttribute = [ NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 18.0)! ]
            let attributedString = NSAttributedString(string: "Send", attributes: titleAttribute)
            sendButton.setAttributedTitle(attributedString, for: .normal)
            sendButton.setTitleColor(.accentColor, for: .normal)
        } else {
            let titleAttribute = [ NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 18.0)!, NSAttributedString.Key.foregroundColor : UIColor.unselectedGrayColor]
            let attributedString = NSAttributedString(string: "Send", attributes: titleAttribute)
            sendButton.setAttributedTitle(attributedString, for: .normal)
            sendButton.setTitleColor(.unselectedGrayColor, for: .normal)
        }
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        guard let text = announcementTextField.text, announcementTextField.text != "" else {
            self.showFailureToast(message: "Empty textfield!")
            return
            
        }
        guard let group = group else { return }
        // Create a URL in the /tmp directory
//        guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempImage.png") else {
//            return
//        }
//
//        let pngData = Authentication.image?.pngData();
//        do {
//            try pngData?.write(to: imageURL);
//        } catch { }
        
        AnnouncementUpload.uploadAnnouncement(text, group: group) { complete, error in
            if let error = error {
                self.showErrorNotification(message: error)
            } else {
                self.showSuccessNotification(message: "Announcement sent!")
                self.dismiss(animated: true)
            }
        }
        
        Functions.functions().httpsCallable("sendAnnouncement").call(["groupID" : group, "announcement" : text]) { result, error in
            if let result = result {
                print("YAYYYYY")
                print(result.data)
            } else {
                print("fuck" + (error?.localizedDescription ?? "(no error)"))
            }
        }
    }
    
}

extension AnnouncementVC: UITextFieldDelegate {
    
}
