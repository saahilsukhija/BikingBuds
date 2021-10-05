//
//  StorageUploads.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/19/21.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

/// Makes it simpler to upload to storage, NOT REALTIME DATABASE
struct StorageUpload {
    
    /// Storage Bucket
    var storage: Storage!
    
    /// Storage Reference
    var storageRef: StorageReference!
    
    init() {
        self.storage = Storage.storage()
        storageRef = storage.reference()
    }
    
    func uploadData(path: String, data: Data, metaData: StorageMetadata? = nil, completion: ((Bool) -> Void)? = nil) {
        let dataRef = storageRef.child(path)
        dataRef.putData(data, metadata: metaData) { metaData, error in
            if let error = error {
                print("error uploading data (StorageUploads.swift): \(error.localizedDescription)")
                completion?(false)
            }
            else {
                completion?(true)
            }
        }
    }
    
    
    /// Turns the current user into a storage friendly user and uploads it
    /// - Parameters:
    ///   - user: The current user, defaults to Authentication.user!
    ///
    ///   - completion: when completed lol
    func uploadCurrentUser(_ user: User = Authentication.user!, phoneNumber: String?, emergencyPhoneNumber: String? = nil, image: UIImage?, completion: ((Bool) -> Void)? = nil) {
        
        let currentUser = Authentication.user!
        
        if image != nil {
            Authentication.imagePath = "pictures/\(currentUser.email!)"
        }
        
        let groupUser = Authentication.turnIntoGroupUser(currentUser, phoneNumber: phoneNumber, emergencyPhoneNumber: emergencyPhoneNumber)

        self.uploadData(path: "users/\(groupUser.email!)", data: groupUser.toData()) { completed in
            if let image = image {
                self.uploadProfilePicture(image, email: groupUser.email) { completed in
                    completion?(completed)
                }
            } else {
                print("no image")
                completion?(completed)
            }
        }
    }
    
    func uploadProfilePicture(_ image: UIImage, email: String, completion: ((Bool) -> Void)? = nil) {
        
        self.uploadData(path: "pictures/\(email)", data: image.pngData()!) { completed in
            completion?(completed)
        }
    }
}
