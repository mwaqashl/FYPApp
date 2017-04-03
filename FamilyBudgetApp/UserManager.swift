

import Foundation
import Firebase

class UserManager {
    
    fileprivate static var singleTonInstance = UserManager()
    fileprivate let ref = FIRDatabase.database().reference()
    let defaultSettings = UserDefaults.standard
    
    static func sharedInstance() -> UserManager {
        return singleTonInstance
    }
    
    
    func setImage(_ user: CurrentUser, callBack:@escaping (Bool) -> Void) {
        
        let data = UIImageJPEGRepresentation(user.image!, 0.5)
        
        let ref = FIRStorage.storage().reference()
        
        ref.child("User").child(user.getUserID()).child(user.imageURL).put(data!, metadata: nil) { (meta, error) in
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
    func addNewUser(_ user: CurrentUser) {
        
        let userInfo = ref.child("Users").child(user.getUserID())
        
        let data : NSMutableDictionary = [
            
            "email": user.getUserEmail(),
            "userName": user.userName,
            "image": user.imageURL,
            "gender": user.gender
        ]
        
        
        if user.birthdate != nil {
            data["birthDate"] = user.birthdate!.timeIntervalSince1970*1000
        }
        data["deviceID"] = user.deviceID
        data["lastSeen"] = FIRServerValue.timestamp()
        
        userInfo.setValue(data)
        
    }
    
    // Update user in Database ! required argument is a user Object. Call this when user logs in or logsout
    func updateUserState(_ user: User) {
        
        let userInfo = ref.child("Users/\(user.getUserID())")
        
        let data : NSDictionary = [
            "userName": user.userName,
            "image": user.imageURL,
            "gender" : user.gender
        ]
        
        data.setValue(FIRServerValue.timestamp(), forKey: "lastSeen")
        
        userInfo.updateChildValues(data as! [AnyHashable:Any])

    }
    
    // Add a new Wallet to User in Database ! required argument is a CurrentUser Object.
    func addWalletInUser(_ userID: String, walletID: String, isPersonal: Bool) {
        
        ref.child("UserWallets/\(userID)/\(walletID)").setValue(isPersonal)
        
    }
    
    // remove wallet from user ! required argument is a userID and WalletID. call this when person is removed from wallet
    func removeWalletFromUser(_ userID: String, walletID: String) {
        ref.child("UserWallets/\(userID)/\(walletID)").removeValue()
    }
    
    // Add a new task for user in Database ! required argument is a userID and task.
    func addTaskToUser(_ userID: String, task: Task) {
        ref.child("UserTasks").child(userID).child(task.id).setValue(true)
    }
    
    // Remove task from user in Database ! required argument is a userID and task.
    func removeTaskFromUser(_ userID: String, task: Task) {
        ref.child("UserTasks").child(userID).child(task.id).removeValue()
    }
    
    // Add user friends to database ! for Rules management
    func addUserFriends(_ member: String, friends: [String]) {
        
        for friend in friends {
            ref.child("UserFriends").child(member).updateChildValues([friend:true])
            ref.child("UserFriends").child(friend).updateChildValues([member:true])
        }
        
    }
    
    // call this function when user logged in to set device to active mode
    func userLoggedIn(_ user: String) {
        // add the device in deviceIDs
        let deviceRef = ref.child("Users").child(user)
        if let deviceToken = defaultSettings.value(forKey: "deviceToken") as? String {
            deviceRef.updateChildValues(["deviceID":deviceToken,"lastSeen": FIRServerValue.timestamp()])
        }
    }
    
    // call this function when user logged out to set device to inactive mode
    func userLoggedOut(_ user: String) {
        let deviceRef = ref.child("Users").child(user).child("deviceID")
        if let deviceToken = defaultSettings.value(forKey: "deviceToken") as? String {
            deviceRef.child(deviceToken).removeValue()
        }
    }
}
