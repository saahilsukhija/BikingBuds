//
//  Group.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/30/21.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

struct Group {
    
    static func generateGroupNumber(completion: @escaping(String) -> Void) {
        let number = resetNumber()

        groupExists(number) { exists in
            if !exists {
                joinGroup(with: number)
                completion(String(number))
            } else {
                print("redo")
                generateGroupNumber { groupNumber in
                    completion(groupNumber)
                }
            }
            
        }
        
    }
    
    static func resetNumber() -> Int {
        return Int.random(in: 100000...999999)
    }
    
    static func uploadGroupName(_ name: String, for id: String) {
        RealtimeUpload.upload(data: name, path: "rides/\(id)/name")
    }
    
    static func joinGroup(with id: Int, checkForExistingIDs: Bool = false, completion: ((Bool) -> Void)? = nil) {
        print("joining...")
        if checkForExistingIDs {
            groupExists(id) { exists in
                if exists {
                    joinGroup(id: id)
                    print("joined")
                    completion?(true)
                } else {
                    print("error joining")
                    completion?(false)
                }
            }
        }
        else {
            print("joined")
            joinGroup(id: id)
        }
    }
    
    private static func joinGroup(id: Int) {
        let currentUser = Authentication.user!
        
        let storage = StorageUpload()
        
        
        storage.storageRef.child("rides/\(id)").getMetadata { metaData, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            var dictionary: [String : String] = metaData?.customMetadata ?? Dictionary()
            
            
            dictionary["\(dictionary.count)"] = currentUser.email!
            
            let ridersMetaData = StorageMetadata()
            ridersMetaData.customMetadata = dictionary
            
            let idData = "\(id)".data(using: .utf8)!
            storage.uploadData(path: "rides/\(id)", data: idData, metaData: ridersMetaData)
        }
    }
    
    static func groupExists(_ id: Int, completion: @escaping(Bool) -> Void) {
        let ref = Database.database().reference().child("rides/\(id)")
        ref.observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
        
    }
}



