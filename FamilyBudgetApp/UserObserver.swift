//
//  UserObserver.swift
//  Penzy
//
//  Created by MacUser on 9/2/16.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation
import Firebase

class UserObserver {
    private var ref = FIRDatabase.database().reference()
    private static var singleInstance : UserObserver?
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
    private func observeUserAdded(){
        let userRef = ref.child("UserDetails")
        userRef.observeEventType(FIRDataEventType.ChildAdded, withBlock:  { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let user = User(id: snapshot.key, email: dict["email"] as! String, userName: dict["userName"] as! String, imageURL: dict["image"] as! String)
            guard let birthday = (dict["birthdate"] as? Double) else {
                Resource.sharedInstance().users[snapshot.key] = user
                Delegate.sharedInstance().getUserDelegates().forEach({ (userDelegate) in
                    userDelegate.userAdded(user)
                })
                return
            }
            let currentUser = CurrentUser(id: user.getUserID(),
                email: user.getUserEmail(),
                userName: user.userName,
                imageURL: user.imageURL,
                birthdate: birthday,
                deviceIDs: dict["devices"] as? [String: AnyObject],
                subscriptionType: (dict["subscriptionType"] as! Int) == 0 ? .None : (dict["subscriptionType"] as! Int) == 1 ? .Monthly : .Yearly,
                lastSubscription: (dict["lastSubscription"] as! Double))
            Resource.sharedInstance().currentUserId = snapshot.key
            Resource.sharedInstance().users[snapshot.key] = currentUser
            self.observeTransactionRequest(currentUser)
            Delegate.sharedInstance().getUserDelegates().forEach({ (userDel) in
                userDel.userDetailsAdded(currentUser)
            })
        })
    }
    private func observeUserUpdated(){
        let userRef = ref.child("UserDetails")
        userRef.observeEventType(FIRDataEventType.ChildChanged, withBlock:  { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let user = User(id: snapshot.key, email: dict["email"] as! String, userName: dict["userName"] as! String, imageURL: dict["image"] as! String)
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
            currentUser.birthdate = NSDate(timeIntervalSince1970: devices/1000 )
            currentUser.deviceIDs = (dict["devices"] as? [String: AnyObject]) != nil ? (dict["devices"] as? [String: AnyObject])! : ([:])
            currentUser.subscriptionType = helperFunctions.getSubscriptionType(dict["subscriptionType"] as! Int)
            currentUser.lastSubscription = dict["lastSubscription"] != nil ? NSDate(timeIntervalSince1970: (dict["lastSubscription"] as! Double)/1000) : nil
            Resource.sharedInstance().currentUserId = snapshot.key
            Resource.sharedInstance().users[snapshot.key] = currentUser
            Delegate.sharedInstance().getUserDelegates().forEach({ (userDel) in
                userDel.userDetailsAdded(currentUser)
            })
        })
    }
    private func observeTransactionRequest(user : CurrentUser){
        let requestRef = ref.child("TransactionRequests").child(user.getUserID())
        requestRef.observeEventType(FIRDataEventType.ChildAdded, withBlock: {(snapshot) in
            guard let dict = snapshot.value else {
                return
            }
            let request = TransactionRequest(id: snapshot.key, payeeId: user.getUserID(), transactionId: dict["transactionID"] as! String, walletId: dict["walletID"] as! String)
            Resource.sharedInstance().transactionRequests[snapshot.key] = request
            Delegate.sharedInstance().getTransactionRequestDelegates().forEach({ (transReqDel) in
                transReqDel.transactionRequestArrived(request)
            })
        })
        
        requestRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock: {(snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().transactionRequests[snapshot.key] = nil
        })
    }
}