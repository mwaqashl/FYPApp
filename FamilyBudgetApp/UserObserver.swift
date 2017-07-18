

import Foundation
import Firebase

class UserObserver {
    fileprivate var ref = Database.database().reference()
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
        Database.database().reference().child("Users").removeAllObservers()
    }
    fileprivate func observeUserAdded(){
        let userRef = ref.child("Users")
        userRef.observe(DataEventType.childAdded, with:  { (snapshot) in
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
            guard let birthDate = dict["birthDate"] as? Double else{
                return
            }
            let currentUser = CurrentUser(id: user.getUserID(), email: user.getUserEmail(), userName: user.userName, imageURL: user.imageURL, birthdate: birthDate/1000, deviceID: dict["deviceID"] as? String, gender: user.gender)
            Resource.sharedInstance().users[snapshot.key] = currentUser
            Delegate.sharedInstance().getUserDelegates().forEach({ (userDel) in
                userDel.userDetailsAdded(currentUser)
            })
        })
    }
    fileprivate func observeUserUpdated(){
        let userRef = ref.child("Users")
        userRef.observe(DataEventType.childChanged, with:  { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let user = User(id: snapshot.key, email: dict["email"] as! String, userName: dict["userName"] as! String, imageURL: dict["image"] as! String, gender: dict["gender"] as! Int)
            print(dict)
            guard let birthDate = dict["birthDate"] as? Double else{
                Resource.sharedInstance().users[snapshot.key] = user
                Delegate.sharedInstance().getUserDelegates().forEach({ (userDelegate) in
                    userDelegate.userUpdated(user)
                })
                return
            }
            let currentUser = CurrentUser(id: user.getUserID(), email: user.getUserEmail(), userName: user.userName, imageURL: user.imageURL, birthdate: birthDate/1000, deviceID: dict["deviceID"] as? String, gender: user.gender)
            Resource.sharedInstance().users[snapshot.key] = currentUser
            Delegate.sharedInstance().getUserDelegates().forEach({ (userDel) in
                userDel.userDetailsUpdated(currentUser)
            })
        })
    }
}
