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
        var hasFound = false
        var number = resetNumber()
        
        getExistingIDs { [self] existingIDs in
            
            while !hasFound {
                
                if !groupExists(number, ids: existingIDs) {
                    hasFound = true
                    joinGroup(with: number)
                    completion(String(number))
                } else {
                    print("redo")
                    number = resetNumber()
                }
            }
        }
    }
    
    static func resetNumber() -> Int {
        return Int.random(in: 100000...999999)
    }
    
    static func joinGroup(with id: Int, checkForExistingIDs: Bool = false, completion: ((Bool) -> Void)? = nil) {
        print("joining...")
        if checkForExistingIDs {
            
            getExistingIDs { ids in
                if groupExists(id, ids: ids) {
                    joinGroup(id: id)
                    print("joined")
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        }
        else {
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
    
    static func groupExists(_ id: Int, ids: NSDictionary) -> Bool {

        return (ids.allKeys as! [String]).contains(String(id))
    }
    
    static func getExistingIDs(completion: @escaping(NSDictionary) -> Void) {
        
        var existingIDs: NSDictionary!
        let ref = Database.database().reference().child("rides")

        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                existingIDs = (snapshot.value as! NSDictionary)
            } else {
                existingIDs = NSDictionary()
            }
        
            completion(existingIDs)
        }
    }
}



