//
//  StorageUploads.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/19/21.
//

import UIKit
import FirebaseStorage

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
    
    func uploadData(path: String, data: Data) {
        let dataRef = storageRef.child(path)
        dataRef.putData(data)
    }
    
    ///Upload the user object to the storage cloud
    func uploadUserObject() {
        
        let userData = [User.firstName, User.lastName, User.phoneNumber]
        
        do {
            let data = try HelperFunctions.encodeToJSON(userData).data(using: .utf8)!
            uploadData(path: "users/\(User.email!)/", data: data)
        } catch {
            print("error encoding user object")
        }
    }
}
