//
//  ChatObserver.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 26/05/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import Foundation
import Firebase

class ChatObserver {
    
    fileprivate var ref = Database.database().reference()
    fileprivate static var singleInstance : ChatObserver?
    class func sharedInstance() -> ChatObserver {
        guard let instance = ChatObserver.singleInstance else {
            ChatObserver.singleInstance = ChatObserver()
            return singleInstance!
        }
        return instance
    }
    fileprivate var isObservingChatOf : [String] = []
    fileprivate var _autoObserve : Bool = true
    var autoObserve : Bool {
        get { return _autoObserve } set {
            if newValue {
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    ChatObserver.sharedInstance().startObserving(wallet: wallet)
                })
            }else{
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    ChatObserver.sharedInstance().stopObserving(wallet: wallet)
                })
            }
            _autoObserve = newValue
        }
    }
    
    func startObserving(wallet: UserWallet) {
        
        if !isObservingChatOf.contains(wallet.id) {
            observeChat(ofWallet: wallet)
            isObservingChatOf.append(wallet.id)
        }
        
    }
    func stopObserving(wallet : UserWallet){
        Database.database().reference().child("Chat").child(wallet.id).removeAllObservers()
        if isObservingChatOf.contains(wallet.id){
            isObservingChatOf.remove(at: isObservingChatOf.index(of: wallet.id)!)
        }
    }
    
    
    func observeChat(ofWallet wallet: UserWallet) {
        
        let chatRef = ref.child("Chat").child(wallet.id)
        
        chatRef.observe(.childAdded, with: { (snap) in
            
            guard let data = snap.value as? Dictionary<String, Any> else{
                print("Error! Data is not dictionary", #function)
                return
            }
            print(data)
            let message = Message(id: snap.key, message: data["message"] as! String, date: data["timestamp"] as! Double , senderID: data["sender"] as! String, walletID: wallet.id)
            
            let dels = Delegate.sharedInstance().getChatDelegates()

            guard var messages = Resource.sharedInstance().walletChat[wallet.id] else {
                Resource.sharedInstance().walletChat[wallet.id] = [message]
                for del in dels {
                    del.newMessageArrived(message: message)
                }
                return
            }
            messages.append(message)
            Resource.sharedInstance().walletChat[wallet.id] = messages
            for del in dels {
                del.newMessageArrived(message: message)
            }
        })
        
    }
    
    
}

protocol ChatDelegate {
    
    func newMessageArrived(message: Message)
    
}
