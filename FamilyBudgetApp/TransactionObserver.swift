//
//  TransactionObserver.swift
//  Penzy
//
//  Created by MacUser on 9/9/16.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation
import Firebase

class TransactionObserver {
    private let FIRKeys = ["Transactions", //0
        "RecurringTransactions", //1
        "walletID", //2
        "transactionID", //3
        "amount", //4
        "categoryID", //5
        "comments", //6
        "lastDate", //7
        "pictureURL", //8
        "transactionBy", //9
        "currency", //10
        "venue", //11
        "recurringDays", //12
        "isExpense", //13
        "date" ] //14
    
    private var ref = FIRDatabase.database().reference()
    private static var singleInstance : TransactionObserver?
    class func sharedInstance() -> TransactionObserver {
        guard let instance = TransactionObserver.singleInstance else {
            TransactionObserver.singleInstance = TransactionObserver()
            return singleInstance!
        }
        return instance
    }
    func startObservingTransaction(ofWallet wallet : UserWallet){
        stopObservingTransaction(ofWallet: wallet)
        observeTransactionAdded(wallet)
        observeTransactionUpdated(wallet)
        observeTransactionDeleted(wallet)
    }
    func stopObservingTransaction(ofWallet wallet : UserWallet){
        FIRDatabase.database().reference().child(FIRKeys[0]).child(wallet.id).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[1]).child(wallet.id).removeAllObservers()
    }
    private func observeTransactionAdded(wallet: UserWallet) {
        let transactionRef = ref.child(FIRKeys[0]).child(wallet.id)
        transactionRef.observeEventType(FIRDataEventType.ChildAdded, withBlock: {(snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let transaction = Transaction(transactionId: snapshot.key,
                amount: dict[self.FIRKeys[4]] as! Double,
                categoryId: dict[self.FIRKeys[5]] as! String,
                comments: dict[self.FIRKeys[6]] as? String,
                date: (dict[self.FIRKeys[14]] as! Double),
                venue: dict[self.FIRKeys[11]] as? [String: AnyObject],
                pictureURLs: dict[self.FIRKeys[8]] as? [String],
                transactionById: dict[self.FIRKeys[9]] as! String,
                currencyId: dict[self.FIRKeys[10]] as! String,
                isExpense: dict[self.FIRKeys[13]] as! Bool,
                walletID: dict[self.FIRKeys[2]] as! String)
            Resource.sharedInstance().transactions[snapshot.key] = transaction
            Delegate.sharedInstance().getTransactionDelegates().forEach({ (transactionDel) in
                transactionDel.transactionAdded(transaction)
            })
        })
        
        let recTransactionRef = ref.child(FIRKeys[1]).child(wallet.id)
        recTransactionRef.observeEventType(FIRDataEventType.ChildAdded, withBlock: {(snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let transaction = Transaction(transactionId: snapshot.key,
                amount: dict[self.FIRKeys[4]] as! Double,
                categoryId: dict[self.FIRKeys[5]] as! String,
                comments: dict[self.FIRKeys[6]] as? String,
                date: (dict[self.FIRKeys[14]] as! Double),
                venue: dict[self.FIRKeys[11]] as? [String: AnyObject],
                pictureURLs: dict[self.FIRKeys[8]] as? [String],
                transactionById: dict[self.FIRKeys[9]] as! String,
                currencyId: dict[self.FIRKeys[10]] as! String,
                isExpense: dict[self.FIRKeys[13]] as! Bool,
                walletID: dict[self.FIRKeys[2]] as! String)
            let recTransaction = RecurringTransaction(days: dict[self.FIRKeys[12]] as! Int, transaction: transaction)
            Resource.sharedInstance().recurringTransactions[snapshot.key] = recTransaction
            Delegate.sharedInstance().getRecurTransactionDelegates().forEach({ (transactionDel) in
                transactionDel.transactionAdded(recTransaction)
            })
        })
    }
    private func observeTransactionUpdated(wallet: UserWallet) {
        let transactionRef = ref.child(FIRKeys[0]).child(wallet.id)
        transactionRef.observeEventType(FIRDataEventType.ChildChanged, withBlock: {(snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let transaction = Resource.sharedInstance().transactions[snapshot.key]!
            transaction.amount = dict[self.FIRKeys[4]] as! Double
            transaction.categoryId = dict[self.FIRKeys[5]] as! String
            transaction.comments = dict[self.FIRKeys[6]] as? String
            transaction.venue = dict[self.FIRKeys[11]] as? [String: AnyObject]
            transaction.pictureURLs = dict[self.FIRKeys[8]] as? [String]
            transaction.currencyId = dict[self.FIRKeys[10]] as! String
            transaction.isExpense = dict[self.FIRKeys[13]] as! Bool
            Resource.sharedInstance().transactions[snapshot.key] = transaction
            Delegate.sharedInstance().getTransactionDelegates().forEach({ (transactionDel) in
                transactionDel.transactionUpdated(transaction)
            })
        })
        
        let recTransactionRef = ref.child(FIRKeys[1]).child(wallet.id)
        recTransactionRef.observeEventType(FIRDataEventType.ChildChanged, withBlock: {(snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let recTransaction = Resource.sharedInstance().recurringTransactions[snapshot.key]!
            recTransaction.amount = dict[self.FIRKeys[4]] as! Double
            recTransaction.categoryId = dict[self.FIRKeys[5]] as! String
            recTransaction.comments = dict[self.FIRKeys[6]] as? String
            recTransaction.venue = dict[self.FIRKeys[11]] as? [String: AnyObject]
            recTransaction.pictureURLs = dict[self.FIRKeys[8]] as? [String]
            recTransaction.currencyId = dict[self.FIRKeys[10]] as! String
            recTransaction.isExpense = dict[self.FIRKeys[13]] as! Bool
            recTransaction.recurringDays = dict[self.FIRKeys[12]] as! Int
            Resource.sharedInstance().recurringTransactions[snapshot.key] = recTransaction
            Delegate.sharedInstance().getRecurTransactionDelegates().forEach({ (transactionDel) in
                transactionDel.transactionUpdated(recTransaction)
            })
        })
    }
    private func observeTransactionDeleted(wallet: UserWallet) {
        let transactionRef = ref.child(FIRKeys[0]).child(wallet.id)
        transactionRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock: {(snapshot) in
            guard (snapshot.value as? NSDictionary) != nil else {
                return
            }
            let transaction = Resource.sharedInstance().transactions[snapshot.key]!
            Resource.sharedInstance().transactions[snapshot.key] = nil
            Delegate.sharedInstance().getTransactionDelegates().forEach({ (transactionDel) in
                transactionDel.transactionDeleted(transaction)
            })
        })
        
        let recTransactionRef = ref.child(FIRKeys[1]).child(wallet.id)
        recTransactionRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock: {(snapshot) in
            guard (snapshot.value as? NSDictionary) != nil else {
                return
            }
            let recTransaction = Resource.sharedInstance().recurringTransactions[snapshot.key]!
            Resource.sharedInstance().recurringTransactions[snapshot.key] = nil
            Delegate.sharedInstance().getRecurTransactionDelegates().forEach({ (transactionDel) in
                transactionDel.transactionDeleted(recTransaction)
            })
        })
    }
}
