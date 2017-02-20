//
//  User.swift
//  AccBook
//
//  Created by MacUser on 8/16/16.
//  Copyright © 2016 Collage. All rights reserved.
//

import Foundation
import Firebase

enum SubscriptionType {
    case None, Monthly, Yearly
}
let url = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
class User {
    private var id : String
    private var email : String
    var userName : String
    var imageURL : String
    var image  : UIImage?
    init(id : String, email : String, userName : String, imageURL : String) {
        self.id = id
        self.email = email
        self.userName = userName
        self.imageURL = imageURL
    }
    
    func getUserID() -> String {
        return id
    }
    
    func getUserEmail() -> String {
        return email
    }
    
    func getImage(completion : (NSData) -> ()) {
        let fileManager = NSFileManager.defaultManager()
        let imageNSURL = url.URLByAppendingPathComponent("images/userImages/\(self.id)/\(self.imageURL)")
        if fileManager.fileExistsAtPath(imageNSURL.absoluteString) {
            let data = NSData(contentsOfURL: imageNSURL)
            completion(data!)
        }else{
            let imageRef = FIRStorage.storage().referenceForURL("gs://penzy-120d0.appspot.com").child("images").child("userImages").child(self.id).child(self.imageURL)
            imageRef.writeToFile(imageNSURL, completion: { (url, error) in
                guard error == nil else {
                    return
                }
                let data = NSData(contentsOfURL: url!)!
                completion(data)
            })
        }
    }
}

class CurrentUser : User {
    var birthdate : NSDate?
    var deviceIDs : [String: AnyObject]
    var subscriptionType : SubscriptionType
    var lastSubscription : NSDate?
    private var wallets : [Wallet]{
        var _wallets : [Wallet] = []
        for (key,value) in Resource.sharedInstance().userWallets {
            if walletIDs.contains(key) {
                _wallets.append(value)
            }
        }
        return _wallets
    }
    private var walletIDs : [String]{
        var _walletIDs : [String] = []
        Resource.sharedInstance().userWallets.forEach { (key, wallets) in
            if wallets.memberTypes[self.id] != nil {
                _walletIDs.append(key)
            }
        }
        return _walletIDs
    }
    private var tasks : [Task] {
        var _tasks : [Task] = []
        for (key,value) in Resource.sharedInstance().tasks {
            if taskIDs.contains(key) {
                _tasks.append(value)
            }
        }
        return _tasks
    }
    private var taskIDs : [String] {
        var _taskIDs : [String] = []
        Resource.sharedInstance().tasks.forEach { (key, tasks) in
            if tasks.memberIDs.contains(self.id) {
                _taskIDs.append(key)
            }
        }
        return _taskIDs
    }
    
    
    
    init(id : String, email : String, userName : String, imageURL : String, birthdate : Double?, deviceIDs : [String: AnyObject]?, subscriptionType : SubscriptionType, lastSubscription : Double?) {
        if birthdate != nil {
            self.birthdate = NSDate(timeIntervalSince1970: birthdate!/1000)
        }
        self.deviceIDs = deviceIDs != nil ? deviceIDs! : [:]
        self.subscriptionType = subscriptionType
        if lastSubscription != nil {
            self.lastSubscription = NSDate(timeIntervalSince1970: lastSubscription!/1000)
        }
        super.init(id: id, email: email, userName: userName, imageURL: imageURL)
    }
    
    func getUserSubscription() -> SubscriptionType {
        return subscriptionType
    }
    func userLastSubscriptionDate() -> NSDate? {
        return lastSubscription
    }
    func isSubscriptionValid() -> Bool {
        
        switch subscriptionType {
        case .None:
            return false
        case .Monthly:
            
            // Check if date is not Expired !
            
            
            return true
            
        case .Yearly:
            
            // Check if date is not Expired !
            
            return true
            
        }
        
    }
    func addDevice(deviceID: String) {
        deviceIDs[deviceID] = true
    }
    func removeDevice(deviceID: String) {
        deviceIDs[deviceID] = false
    }
    
    
}

protocol UserDelegate {
    func userDetailsAdded(user: CurrentUser)
    func userDetailsUpdated(user: CurrentUser)
    func userAdded(user : User)
    func userUpdated(user : User)
}