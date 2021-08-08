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
    
    func uploadPhoneNumber(_ phone: String, user: User, completion: ((Bool) -> Void)? = nil) {
        self.uploadData(path: "users/\(user.email!)/phone", data: phone.data(using: .utf8)!) { completed in
            if completed {
                completion?(true)
            } else {
                completion?(false)
            }
        }
        
    }
}
