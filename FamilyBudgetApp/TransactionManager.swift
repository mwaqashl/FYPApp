//
//  TransactionManager.swift
//  Penzy
//
//  Created by Waqas Hussain on 31/08/2016.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation
import Firebase

class TransactionManager {
    
    private var ref = FIRDatabase.database().reference()
    private static var singleTonInstance = TransactionManager()
    
    static func sharedInstance() -> TransactionManager {
        return singleTonInstance
    }
    
    /**
     Add a new transaction
     Call this method when a new transaction is perform in a wallet
     
     
     :param: Newly made Transaction
     
     */
    func AddTransactionInWallet(transaction: Transaction) {
        
        let transRef = ref.child("Transactions/\(transaction.walletID)").childByAutoId()
        
        let data : NSMutableDictionary = [
            "amount":transaction.amount,
            "categoryID":transaction.categoryId,
            "date":FIRServerValue.timestamp(),
            "transactionBy": transaction.transactionById,
            "currency": transaction.currencyId,
            "isExpense": transaction.isExpense
        ]
        
        if transaction.comments != nil {
            data["comments"] = transaction.comments
        }
        
        if transaction.venue != nil {
        
            let venue : NSMutableDictionary = [
                "name": transaction.venue!["name"]!
            ]
            
            if transaction.venue!["lat"] != nil {
                venue["lat"] = transaction.venue!["lat"]!
                venue["long"] = transaction.venue!["long"]!
            }
            
            data["venue"] = venue
        }
        
        if transaction.pictureURLs != nil {
            data["pictureURLs"] = transaction.pictureURLs
        }
        
        transRef.setValue(data)
        
        // If transaction is a recurring Transaction
        if let transaction = transaction as? RecurringTransaction {
            data.removeObjectForKey("date")
            data["lastDate"] = transaction.date
            data["recurringDays"] = transaction.recurringDays
            
            ref.child("RecurringTransactions/\(transaction.walletID)").childByAutoId().setValue(data)
        }
        
        updateWalletFromTransaction(transaction)
        
    }
    
    /**
     Update Wallet From transaction.
     perform the required changes to wallet which occurs due to transaction in a wallet
     
     :param: Transaction object
     
     */
    private func updateWalletFromTransaction(transaction: Transaction) {
        
        let walletRef = ref.child("Wallets/\(transaction.walletID)")
        
        walletRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var walletData = currentData.value as? [String : AnyObject] {
                
                var balance = walletData["balance"] as! Double
                var totExp = walletData["totExpense"] as! Double
                var totInc = walletData["totIncome"] as! Double
                
                if transaction.isExpense {
                    balance -= transaction.amount
                    totExp += transaction.amount
                }
                else {
                    balance += transaction.amount
                    totInc += transaction.amount
                }
                
                walletData["balance"] = balance
                walletData["totIncome"] = totInc
                walletData["totExpense"] = totExp
                
                currentData.value = walletData
                
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)

        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    
    /**
     Update Wallet when a transaction is edited by user
     It checks if the balance is edited or not and perform the changes accordingly
     
     :param: updated transaction object
     
     */
    func updateTransactionInWallet(transaction: Transaction) {
        
        var transRef = ref.child("Transactions/\(transaction.walletID)/\(transaction.id))")
        
        if (transaction is RecurringTransaction) {
            
            transRef = ref.child("RecurringTransactions/\(transaction.walletID)/\(transaction.id))")
            
            let data : NSMutableDictionary = [
                "amount":transaction.amount,
                "categoryID":transaction.categoryId,
                "date":transaction.date.timeIntervalSince1970*1000,
                "currency": transaction.currencyId,
                "isExpense": transaction.isExpense
            ]
            
            if transaction.comments != nil {
                data["comments"] = transaction.comments
            }
            
            if transaction.venue != nil {
                
                let venue : NSMutableDictionary = [
                    "name": transaction.venue!["name"]!
                ]
                
                if transaction.venue!["lat"] != nil {
                    venue["lat"] = transaction.venue!["lat"]!
                    venue["long"] = transaction.venue!["long"]!
                }
                
                data["venue"] = venue
            }
            
            if transaction.pictureURLs != nil {
                data["pictureURLs"] = transaction.pictureURLs
            }
            
            transRef.updateChildValues(data as [NSObject : AnyObject])
            
        }
        else {
            
            if let oldTrans = Resource.sharedInstance().transactions[transaction.id] {
                
                if oldTrans.amount == transaction.amount {
                    
                    let data : NSMutableDictionary = [
                        "amount":transaction.amount,
                        "categoryID":transaction.categoryId,
                        "date":transaction.date.timeIntervalSince1970*1000,
                        "currency": transaction.currencyId,
                        "isExpense": transaction.isExpense
                    ]
                    
                    if transaction.comments != nil {
                        data["comments"] = transaction.comments
                    }
                    
                    if transaction.venue != nil {
                        
                        let venue : NSMutableDictionary = [
                            "name": transaction.venue!["name"]!
                        ]
                        
                        if transaction.venue!["lat"] != nil {
                            venue["lat"] = transaction.venue!["lat"]!
                            venue["long"] = transaction.venue!["long"]!
                        }
                        
                        data["venue"] = venue
                    }
                    
                    if transaction.pictureURLs != nil {
                        data["pictureURLs"] = transaction.pictureURLs
                    }
                    
                    transRef.updateChildValues(data as [NSObject : AnyObject])
                    
                }
                else {
                    
                    transRef.runTransactionBlock({ (currentData) -> FIRTransactionResult in
                        
                        if var walletData = currentData.value as? [String:AnyObject] {
                            
                            walletData["amount"] = transaction.amount
                            walletData["categoryID"] = transaction.categoryId
                            walletData["date"] = transaction.date.timeIntervalSince1970*1000
                            walletData["currency"] = transaction.currencyId
                            walletData["isExpense"] = transaction.isExpense
                            
                            if transaction.comments != nil {
                                walletData["comments"] = transaction.comments
                            }
                            
                            if transaction.venue != nil {
                                
                                let venue : NSMutableDictionary = [
                                    "name": transaction.venue!["name"]!
                                ]
                                
                                if transaction.venue!["lat"] != nil {
                                    venue["lat"] = transaction.venue!["lat"]!
                                    venue["long"] = transaction.venue!["long"]!
                                }
                                
                                walletData["venue"] = venue
                            }
                            
                            if transaction.pictureURLs != nil {
                                walletData["pictureURLs"] = transaction.pictureURLs
                            }
                            
                            var balance = walletData["balance"] as! Double
                            var totExp = walletData["totExpense"] as! Double
                            var totInc = walletData["totIncome"] as! Double
                            
                            if transaction.isExpense {
                                balance -= transaction.amount - oldTrans.amount
                                totExp += transaction.amount - oldTrans.amount
                            }
                            else {
                                balance += transaction.amount - oldTrans.amount
                                totInc += transaction.amount - oldTrans.amount
                            }
                            
                            walletData["balance"] = balance
                            walletData["totIncome"] = totInc
                            walletData["totExpense"] = totExp
                            
                            return FIRTransactionResult.successWithValue(currentData)
                        }
                        
                        return FIRTransactionResult.successWithValue(currentData)
                        
                        }, andCompletionBlock: { (error, commit, data) in
                            
                            if error != nil {
                                print(error?.localizedDescription)
                            }
                            
                    })
                    
                }
                
            }
            
        }
        
    }
    
    /**
     Undo a transaction from wallet
     Deletes the transaction from database and perfrorm required changes in wallet !
     
     */
    func removeTransactionInWallet(transaction: Transaction, wallet: UserWallet) {
        
        ref.child("Transactions/\(wallet.id)\(transaction)").removeValue()
        
        ref.child("Wallets").child(wallet.id).runTransactionBlock { (currentData) -> FIRTransactionResult in
            
            if var walletData = currentData.value as? [String:AnyObject] {
                
                if transaction.isExpense {
                    walletData["balance"] = wallet.balance + transaction.amount
                    walletData["totExpense"] = wallet.totalExpense - transaction.amount
                }
                else {
                    walletData["balance"] = wallet.balance - transaction.amount
                    walletData["totIncome"] = wallet.totalIncome - transaction.amount
                }
                
                currentData.value = walletData
                return FIRTransactionResult.successWithValue(currentData)
            }
            
            return FIRTransactionResult.successWithValue(currentData)
        }
        
    }
    
    // Working !
    func requestTransaction(request: TransactionRequest) {
        
        let reqRef = ref.child("TransactionRequests").child(request.payeeId).childByAutoId()
        
        reqRef.setValue(["transactionID":request.transactionId,"walletID":request.walletId])
        
    }
    
    func removeRequestTransaction(request: TransactionRequest) {
        
        ref.child("TransactionRequests").child(request.payeeId).child(request.requestID).removeValue()
    }
    
}