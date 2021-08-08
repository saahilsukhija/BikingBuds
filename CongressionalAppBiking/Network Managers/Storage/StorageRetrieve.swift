//
//  StorageRetrieve.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/5/21.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
///Makes it simpler to retrieve data from firebase STORAGE. NOT REALTIME.
struct StorageRetrieve {
    /// Storage Bucket
    var storage: Storage!
    
    /// Storage Reference
    var storageRef: StorageReference!
    
    init() {
        self.storage = Storage.storage()
        storageRef = storage.reference()
    }
    
    func retrieveData(path: String, completion: @escaping(Data?) -> Void) {
        let dataRef = storageRef.child(path)
        
        dataRef.getData(maxSize: 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else {
                completion(data)
            }
        }
    }
    
    func retrieveMetaData(path: String, completion: @escaping(StorageMetadata?) -> Void) {
        let dataRef = storageRef.child(path)
        
        dataRef.getMetadata { metaData, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else {
                completion(metaData)
            }
        }
    }
    
    func getPhoneNumber(from user: User, completion: @escaping(String) -> Void) {
        self.retrieveData(path: "users/\(user.email!)/phone") { numberData in
            if let data = numberData {
                completion(String(data: data, encoding: .utf8)!)
            } else {
                completion("")
            }
            
        }
    }
}
