//
//  StorageRetrieve.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/5/21.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import FirebaseUI
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
        
        //2MB of data max
        dataRef.getData(maxSize: 1024 * 1024 * 2) { data, error in
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
    
    func getProfilePicture(from email: String, completion: @escaping(UIImage?) -> Void) {
        let dataRef = storageRef.child("pictures/\(email)")
        dataRef.write(toFile: URL(string: "pictures/\(email)")!)
        self.retrieveData(path: "pictures/\(email)") { imageData in
            if let imageData = imageData {
                let image = UIImage(data: imageData)
                completion(image)
                Authentication.image = image
            } else {
                completion(nil)
            }
        }
    }
    
    func setProfilePicture(for imageView: UIImageView, email: String) {
        imageView.sd_setImage(with: storageRef.child("pictures/\(email)"))
    }
    
    func getPhoneNumber(from user: User, completion: @escaping(String?) -> Void) {
        self.getGroupUser(from: user.email!) { user in
            completion(user?.phoneNumber)
        }
    }
    
    func getGroupUser(from email: String, completion: @escaping(GroupUser?) -> Void) {
        self.retrieveData(path: "users/\(email)") { data in
            
            do {
                let groupUser = try JSONDecoder().decode(GroupUser.self, from: data ?? Data())
                
                self.getProfilePicture(from: email) { image in
                    if let image = image {
                        groupUser.profilePicture = image.pngData()
                    }
                    completion(groupUser)
                }
            } catch {
                completion(nil)
            }
        }
    }
    
    func getGroupUsers(from emails: [String], completion: @escaping([GroupUser]) -> Void) {
        var groupUsers: [GroupUser] = []
        
        for email in emails {
            self.getGroupUser(from: email) { groupUser in
                if let groupUser = groupUser {
                    groupUsers.append(groupUser)
                }
                
                //return when for loop will end
                if email == emails.last {
                    completion(groupUsers)
                }
            }
            
        }
    }
}
