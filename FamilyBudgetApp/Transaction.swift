//
//  Transaction.swift
//  AccBook
//
//  Created by MacUser on 8/17/16.
//  Copyright © 2016 Collage. All rights reserved.
//

import Foundation
import Firebase

class Transaction {
    
    var id : String
    var amount : Double
    var category : Category? {
        return Resource.sharedInstance().categories[categoryId]
    }
    var categoryId : String
    var comments : String?
    var date : NSDate
    var venue : [String:AnyObject]?
    var pictureURLs : [String]?
    var transactionBy : User? {
        return Resource.sharedInstance().users[transactionById]
    }
    var transactionById : String
    var currency : Currency? {
        return Resource.sharedInstance().currencies[currencyId]
    }
    var currencyId :  String
    var isExpense : Bool
    var walletID: String
    var wallet : UserWallet? {
        return Resource.sharedInstance().userWallets[walletID]
    }
    
    
    init(transactionId : String, amount : Double, categoryId : String, comments : String?, date : Double, venue : [String:AnyObject]?, pictureURLs : [String]?, transactionById : String, currencyId : String, isExpense : Bool, walletID: String) {
        self.id = transactionId
        self.amount = amount
        self.categoryId = categoryId
        self.comments = comments
        self.currencyId = currencyId
        self.date = NSDate(timeIntervalSince1970: date/1000)
        self.venue = venue
        self.isExpense = isExpense
        self.pictureURLs = pictureURLs
        self.transactionById = transactionById
        self.walletID = walletID
    }
    func getImage(urlS: String, completion : (NSData) -> ()) {
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
        let imageNSURL = url.URLByAppendingPathComponent("images/userImages/\(self.id)/\(urlS)")
        if fileManager.fileExistsAtPath(imageNSURL.absoluteString) {
            let data = NSData(contentsOfURL: imageNSURL)
            completion(data!)
        }else{
            let imageRef = FIRStorage.storage().referenceForURL("gs://penzy-120d0.appspot.com").child("images").child("transactionImages").child(self.id).child(urlS)
            imageRef.writeToFile(imageNSURL, completion: { (urlRef, error) in
                guard error == nil else {
                    return
                }
                let data = NSData(contentsOfURL: urlRef!)!
                completion(data)
            })
        }
    }
    
    
}


class RecurringTransaction : Transaction {
    
    var recurringDays : Int
    
    init(days: Int, transaction: Transaction) {
        
        self.recurringDays = days
        super.init(transactionId: transaction.id, amount: transaction.amount, categoryId: transaction.categoryId, comments: transaction.comments, date: transaction.date.timeIntervalSince1970, venue: transaction.venue, pictureURLs: transaction.pictureURLs, transactionById: transaction.transactionById, currencyId: transaction.currencyId, isExpense: transaction.isExpense, walletID: transaction.walletID)
    }
    
}


class TransactionRequest {
    
    var payee: User? {
        return Resource.sharedInstance().users[payeeId]
    }
    var payeeId : String
    var requestID: String
    var transaction: Transaction? {
        return Resource.sharedInstance().transactions[transactionId]
    }
    var transactionId : String
    var wallet: Wallet? {
        return Resource.sharedInstance().userWallets[walletId]
    }
    var walletId : String
    
    init(id: String, payeeId: String, transactionId: String, walletId: String) {
        
        self.payeeId = payeeId
        self.requestID = id
        self.transactionId = transactionId
        self.walletId = walletId
        
    }
}

protocol TransactionDelegate {
    func transactionAdded(transaction : Transaction)
    func transactionUpdated(transaction :  Transaction)
    func transactionDeleted(transaction :  Transaction)
}
protocol ScheduledTransactionDelegate {
    func transactionAdded(transaction : RecurringTransaction)
    func transactionDeleted(transaction : RecurringTransaction)
    func transactionUpdated(transaction : RecurringTransaction)
}
protocol TransactionRequestDelegate {
    func transactionRequestArrived(request : TransactionRequest)
}