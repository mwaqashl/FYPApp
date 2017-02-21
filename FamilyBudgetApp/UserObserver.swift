

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
        FIRDatabase.database().reference().child("UserDetails").removeAllObservers()
    }
    fileprivate func observeUserAdded(){
        let userRef = ref.child("UserDetails")
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
//            self.observeTransactionRequest(currentUser)
//            Delegate.sharedInstance().getUserDelegates().forEach({ (userDel) in
//                userDel.userDetailsAdded(currentUser)
//            })
        })
    }
    fileprivate func observeUserUpdated(){
        let userRef = ref.child("UserDetails")
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
    fileprivate func observeTransactionRequest(_ user : CurrentUser){
        let requestRef = ref.child("TransactionRequests").child(user.getUserID())
        requestRef.observe(FIRDataEventType.childAdded, with: {(snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let request = TransactionRequest(id: snapshot.key, payeeId: user.getUserID(), transactionId: dict["transactionID"] as! String, walletId: dict["walletID"] as! String)
            Resource.sharedInstance().transactionRequests[snapshot.key] = request
            Delegate.sharedInstance().getTransactionRequestDelegates().forEach({ (transReqDel) in
                transReqDel.transactionRequestArrived(request)
            })
        })
        
        requestRef.observe(FIRDataEventType.childRemoved, with: {(snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().transactionRequests[snapshot.key] = nil
        })
    }
}
