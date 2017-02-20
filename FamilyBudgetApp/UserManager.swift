//
//  UserManager.swift
//  Penzy
//
//  Created by Waqas Hussain on 01/09/2016.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation
import Firebase

class UserManager {
    
    private static var singleTonInstance = UserManager()
    private let ref = FIRDatabase.database().reference()
    let defaultSettings = NSUserDefaults.standardUserDefaults()
    
    static func sharedInstance() -> UserManager {
        return singleTonInstance
    }
    
    
    func setImage(user: CurrentUser, callBack:(Bool) -> Void) {
        
        let data = UIImageJPEGRepresentation(user.image!, 0.5)
        
        let ref = FIRStorage.storage().reference()
        
        ref.child("User").child(user.getUserID()).child(user.imageURL).putData(data!, metadata: nil) { (meta, error) in
            if error != nil {
                callBack(false)
                return
            }
            else {
                callBack(true)
                self.updateUserState(user)
            }
            
        }
        
    }
    
    // Add a new User in Database ! required argument is a CurrentUser Object.
    func addNewUser(user: CurrentUser) {
        
        let userInfo = ref.child("UserInfo").child(user.getUserID())
        let userDetail = ref.child("UserDetails/\(userInfo.key)")
        
        let data : NSMutableDictionary = [
            
            "email": user.getUserEmail(),
            "userName": user.userName,
            "image": user.imageURL,
        ]
        
        userInfo.setValue(data)
        
        if user.birthdate != nil {
            data["birthDate"] = user.birthdate!.timeIntervalSince1970*1000
        }
        data["subscriptionType"] = 0
        data["deviceTokens"] = user.deviceIDs
        data["lastSeen"] = FIRServerValue.timestamp()
        
        userDetail.setValue(data)
        
    }
    
    // Update user in Database ! required argument is a user Object. Call this when user logs in or logsout
    func updateUserState(user: User) {
        
        let userInfo = ref.child("UserInfo/\(user.getUserID())")
        let userDetail = ref.child("UserDetails/\(user.getUserID())")
        
        let data : NSMutableDictionary = [
            "userName": user.userName,
            "image": user.imageURL,
        ]
        
        userInfo.updateChildValues(data as [NSObject : AnyObject])
        data["lastSeen"] = FIRServerValue.timestamp()
        
        userDetail.updateChildValues(data as [NSObject : AnyObject])
        
    }
    
    // Add a new User in Database ! required argument is a CurrentUser Object. Call this when user changes it current subscription
    func changeUserSubscription(user: CurrentUser, type: SubscriptionType) {
        let userDetail = ref.child("UserDetails/\(user.getUserID())")
        
        let data : NSMutableDictionary = [
            "subscriptionType":user.subscriptionType.hashValue
        ]
        
        if user.lastSubscription != nil {
            data["lastSubscription"] = user.lastSubscription!.timeIntervalSince1970*1000
        }
        
        userDetail.updateChildValues(data as [NSObject : AnyObject])
    }
    
    // Add a new Wallet to User in Database ! required argument is a CurrentUser Object.
    func addWalletInUser(userID: String, walletID: String, isPersonal: Bool) {
        
        ref.child("UserWallets/\(userID)/\(walletID)").setValue(isPersonal)
        
    }
    
    // remove wallet from user ! required argument is a userID and WalletID. call this when person is removed from wallet
    func removeWalletFromUser(userID: String, walletID: String) {
        
        ref.child("UserWallets/\(userID)/\(walletID)").removeValue()
        
    }
    
    // Add a new task for user in Database ! required argument is a userID and task.
    func addTaskToUser(userID: String, task: Task) {
        
        ref.child("UserTasks/\(userID)/\(task.walletID)/\(task.id)").setValue(true)
        
    }
    
    // Remove task from user in Database ! required argument is a userID and task.
    func removeTaskFromUser(userID: String, task: Task) {
        
        ref.child("UserTasks/\(userID)/\(task.walletID)/\(task.id)").removeValue()
        
    }
    
    // Add user friends to database ! for Rules management
    func addUserFriends(member: String, friends: [String]) {
        
        for friend in friends {
            ref.child("UserFriends").child(member).updateChildValues([friend:true])
            ref.child("UserFriends").child(friend).updateChildValues([member:true])
        }
        
    }
    
    // call this function when user logged in to set device to active mode
    func userLoggedIn(user: String) {
        // add the device in deviceIDs
        let deviceRef = ref.child("UserDetails").child(user).child("devices")
        if let deviceToken = defaultSettings.valueForKey("deviceToken") as? String {
            deviceRef.updateChildValues([deviceToken : true])
        }
        
        // update the users lastSeen value
        let userDetail = ref.child("UserDetails/\(user)")
        let data : NSMutableDictionary = [
            "lastSeen": FIRServerValue.timestamp()
        ]
        userDetail.updateChildValues(data as [NSObject : AnyObject])
    }
    
    // call this function when user logged out to set device to inactive mode
    func userLoggedOut(user: String) {
        let deviceRef = ref.child("UserDetails").child(user).child("devices")
        if let deviceToken = defaultSettings.valueForKey("deviceToken") as? String {
            deviceRef.child(deviceToken).removeValue()
        }
    }
}