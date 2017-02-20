//
//  WalletObserver.swift
//  Penzy
//
//  Created by MacUser on 9/5/16.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation
import Firebase

class WalletObserver {
    private var ref = FIRDatabase.database().reference()
    private var _autoObserve : Bool = true
    var autoObserve : Bool {
        get { return _autoObserve } set {
            if newValue {
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().startObservingWallet(wallet)
                })
            }else{
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().stopObservingWallet(wallet)
                })
            }
            _autoObserve = newValue
        }
    }
    private var _autoObserveTransactions : Bool = true
    var autoObserveTransactions : Bool {
        get { return _autoObserveTransactions } set {
            if newValue {
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().startObservingTransactions(wallet)
                })
            }else{
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().stopObservingTransactions(wallet)
                })
            }
            _autoObserveTransactions = newValue
        }
    }
    private static var singleInstance : WalletObserver?
    class func sharedInstance() -> WalletObserver {
        guard let instance = WalletObserver.singleInstance else {
            WalletObserver.singleInstance = WalletObserver()
            return singleInstance!
        }
        return instance
    }
    func startObserving(){
        observeWalletAdded()
        observeWalletDeleted()
        observeWalletUpdated()
    }
    func startObservingWallet(wallet :  UserWallet){
        stopObservingWallet(wallet)
        observeWalletMemberAdded(wallet);
        observeWalletMemberUpdated(wallet);
        observeWalletMemberRemoved(wallet);
        observeWalletCategoryAdded(wallet);
        observeWalletCategoryUpdated(wallet);
        observeWalletCategoryRemoved(wallet);
        
    }
    func startObservingTransactions(ofWallet: UserWallet){
        TransactionObserver.sharedInstance().startObservingTransaction(ofWallet: ofWallet)
    }
    func stopObservingTransactions(ofWallet : UserWallet){
        TransactionObserver.sharedInstance().stopObservingTransaction(ofWallet: ofWallet)
    }
    func stopObservingWallet(wallet :  UserWallet){
        FIRDatabase.database().reference().child("WalletMembers").child(wallet.id).removeAllObservers()
        FIRDatabase.database().reference().child("WalletCategories").child(wallet.id).removeAllObservers()
    }
    func stopObserving(){
        FIRDatabase.database().reference().child("Wallets").removeAllObservers()
        FIRDatabase.database().reference().child("WalletMembers").removeAllObservers()
        FIRDatabase.database().reference().child("WalletCategories").removeAllObservers()
    }
    
    private func observeWalletAdded(){
        let walletRef = ref.child("Wallets")
        walletRef.observeEventType(FIRDataEventType.ChildAdded, withBlock:  { (snapshot) in
            guard let dict = snapshot.value else {
                return
            }
            let wallet = UserWallet(id: snapshot.key,
                name: dict["name"] as! String, icon: dict["icon"] as! String, currencyID: dict["currency"] as! String, creatorID: dict["creator"] as! String, balance: dict["balance"] as! Double, totInc: dict["totIncome"] as! Double, totExp: dict["totExpense"] as! Double, creationDate: dict["creationDate"] as! Double, isPersonal: dict["isPersonal"] as! Bool, memberTypes: [:], categoryIDs: [], isOpen: dict["isOpen"] as! Bool, color: dict["color"] as! String)
            Resource.sharedInstance().userWallets[snapshot.key] = wallet
            if self.autoObserve { self.startObservingWallet(wallet) }
            Delegate.sharedInstance().getWalletDelegates().forEach({ (walletDel) in
                walletDel.walletAdded(wallet)
            })
        })
    }
    private func observeWalletUpdated() {
        let walletRef = ref.child("Wallets")
        walletRef.observeEventType(FIRDataEventType.ChildChanged, withBlock:  { (snapshot) in
            guard let dict = snapshot.value else {
                return
            }
            let wallet = Resource.sharedInstance().userWallets[snapshot.key]!
            wallet.name = dict["name"] as! String
            wallet.icon = dict["icon"] as! String
            wallet.currencyID = dict["currency"] as! String
            wallet.creatorID = dict["creator"] as! String
            wallet.balance = dict["balance"] as! Double
            wallet.totalIncome = dict["totIncome"] as! Double
            wallet.totalExpense = dict["totExpense"] as! Double
            wallet.creationDate = NSDate(timeIntervalSince1970 : (dict["creationDate"] as! Double)/1000)
            wallet.isPersonal = dict["isPersonal"] as! Bool
            wallet.isOpen = dict["isOpen"] as! Bool
            wallet.color = UIColor(string: dict["color"] as! String)
            Resource.sharedInstance().userWallets[snapshot.key] = wallet
            Delegate.sharedInstance().getWalletDelegates().forEach({ (walletDel) in
                walletDel.walletUpdated(wallet)
            })
        })
    }
    private func observeWalletDeleted(){
        let walletRef = ref.child("Wallets")
        walletRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            guard let wallet = Resource.sharedInstance().userWallets[snapshot.key]  else {
                return
            }
            self.stopObservingWallet(wallet)
            Resource.sharedInstance().userWallets[snapshot.key] = nil
            Delegate.sharedInstance().getWalletDelegates().forEach({ (walletDel) in
                walletDel.WalletDeleted(wallet)
            })
        })
    }
    private func observeWalletMemberAdded(wallet: Wallet){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let walletRef = ref.child("WalletMembers").child(wallet.id)
        walletRef.observeEventType(FIRDataEventType.ChildAdded, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().userWallets[wallet.id]?.addMember(snapshot.key, type: helperFunctions.getMemberType(snapshot.value as! Int))
            guard let user = Resource.sharedInstance().users[snapshot.key] else {
                return
            }
            Delegate.sharedInstance().getWalletMemberDelegates().forEach({ (walletMemDel) in
                walletMemDel.memberAdded(user, ofType : helperFunctions.getMemberType(snapshot.value as! Int), wallet: wallet)
            })
        })
    }
    private func observeWalletMemberUpdated(wallet: Wallet){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let walletRef = ref.child("WalletMembers").child(wallet.id)
        walletRef.observeEventType(FIRDataEventType.ChildChanged, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().userWallets[wallet.id]?.memberTypes[snapshot.key] = helperFunctions.getMemberType(snapshot.value as! Int)
            guard let user = Resource.sharedInstance().users[snapshot.key] else {
                return
            }
            Delegate.sharedInstance().getWalletMemberDelegates().forEach({ (walletMemDel) in
                walletMemDel.memberUpdated(user, ofType : helperFunctions.getMemberType(snapshot.value as! Int), wallet: wallet)
            })
        })
    }
    private func observeWalletMemberRemoved(wallet: Wallet){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let walletRef = ref.child("WalletMembers").child(wallet.id)
        walletRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().userWallets[wallet.id]?.memberTypes[snapshot.key] = nil
            guard let user = Resource.sharedInstance().users[snapshot.key] else {
                return
            }
            Delegate.sharedInstance().getWalletMemberDelegates().forEach({ (walletMemDel) in
                walletMemDel.memberLeft(user, ofType : helperFunctions.getMemberType(snapshot.value as! Int), wallet: wallet)
            })
        })
    }
    private func observeWalletCategoryAdded(wallet : Wallet){
        let walletRef = ref.child("WalletCategories").child(wallet.id)
        walletRef.observeEventType(FIRDataEventType.ChildAdded, withBlock:  { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let category = Category(id: snapshot.key, name: dict["name"] as! String, icon: dict["icon"] as! String, isDefault: false, isExpense: dict["isExpense"] as! Bool, color: dict["color"] as! String)
            Resource.sharedInstance().userWallets[wallet.id]?.addCategory(snapshot.key)
            Resource.sharedInstance().categories[snapshot.key] = category
            Delegate.sharedInstance().getWalletCategoryDelegates().forEach({ (walletCatDel) in
                walletCatDel.categoryAdded(category, wallet: wallet)
            })
        })
    }
    private func observeWalletCategoryUpdated(wallet : Wallet){
        let walletRef = ref.child("WalletCategories").child(wallet.id)
        walletRef.observeEventType(FIRDataEventType.ChildChanged, withBlock:  { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let category = Category(id: snapshot.key, name: dict["name"] as! String, icon: dict["icon"] as! String, isDefault: false, isExpense: dict["isExpense"] as! Bool, color: dict["color"] as! String)
            Resource.sharedInstance().categories[snapshot.key] = category
            Delegate.sharedInstance().getWalletCategoryDelegates().forEach({ (walletCatDel) in
                walletCatDel.categoryUpdated(category, wallet: wallet)
            })
        })
    }
    private func observeWalletCategoryRemoved(wallet : Wallet){
        let walletRef = ref.child("WalletCategories").child(wallet.id)
        walletRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock:  { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let category = Category(id: snapshot.key, name: dict["name"] as! String, icon: dict["icon"] as! String, isDefault: false, isExpense: dict["isExpense"] as! Bool, color: dict["color"] as! String)
            Resource.sharedInstance().userWallets[wallet.id]?.removeCategory(snapshot.key)
            Resource.sharedInstance().categories[snapshot.key] = nil
            Delegate.sharedInstance().getWalletCategoryDelegates().forEach({ (walletCatDel) in
                walletCatDel.categoryRemoved(category, wallet: wallet)
            })
        })
    }
}
