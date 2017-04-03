

import Foundation
import Firebase

class UserObserver {
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate static var singleInstance : UserObserver?
    class func sharedInstance() -> UserObserver {
        guard let instance = UserObserver.singleInstance else {
            UserObserver.singleInstance = UserObserver()
            return singleInstance!
        }
        return instance
    }
    func startObserving(){
        observeUserAdded()
        observeUserUpdated()
    }
    func stopObserving(){
        FIRDatabase.database().reference().child("Users").removeAllObservers()
    }
    fileprivate func observeUserAdded(){
        let userRef = ref.child("Users")
        userRef.observe(FIRDataEventType.childAdded, with:  { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let user = User(id: snapshot.key, email: dict["email"] as! String, userName: dict["userName"] as! String, imageURL: dict["image"] as! String, gender: dict["gender"] as! Int)
            if user.getUserID() == Resource.sharedInstance().currentUserId! {
                return
            }
            Resource.sharedInstance().users[snapshot.key] = user
            Delegate.sharedInstance().getUserDelegates().forEach({ (userDelegate) in
                userDelegate.userAdded(user)
            })
            
        })
    }
    fileprivate func observeUserUpdated(){
        let userRef = ref.child("Users")
        userRef.observe(FIRDataEventType.childChanged, with:  { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let user = User(id: snapshot.key, email: dict["email"] as! String, userName: dict["userName"] as! String, imageURL: dict["image"] as! String, gender: dict["gender"] as! Int)
            guard let devices = dict["birthdate"] as? Double else{
                Resource.sharedInstance().users[snapshot.key] = user
                Delegate.sharedInstance().getUserDelegates().forEach({ (userDelegate) in
                    userDelegate.userUpdated(user)
                })
                return
            }
            let currentUser = Resource.sharedInstance().users[user.getUserID()]! as! CurrentUser
            currentUser.userName = user.userName
            currentUser.imageURL = user.imageURL
            currentUser.birthdate = Date(timeIntervalSince1970: devices/1000 )
            currentUser.deviceID = (dict["deviceID"] as? String)
            Resource.sharedInstance().currentUserId = snapshot.key
            Resource.sharedInstance().users[snapshot.key] = currentUser
            Delegate.sharedInstance().getUserDelegates().forEach({ (userDel) in
                userDel.userDetailsAdded(currentUser)
            })
        })
    }
}
