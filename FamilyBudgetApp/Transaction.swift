

import Foundation
import Firebase

class Transaction {
    
    var id : String
    var amount : Double
    var category : Category {
        if let category = Resource.sharedInstance().categories[categoryId]{
            return category
        }
        return Category(id: categoryId, name: "Loading...", icon: "ꀔ", isDefault: true, isExpense: true, color: textColor.stringRepresentation)
    }
    var categoryId : String
    var comments : String?
    var date : Date
    var transactionBy : User {
        if let user = Resource.sharedInstance().users[transactionById] {
            return user
        }
        return User(id: transactionById, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
    }
    var transactionById : String
    var currency : Currency {
        if let cur = Resource.sharedInstance().currencies[currencyId] {
            return cur
        }
        return Currency(id: currencyId, name: "Currency", icon: "ꀕ", code: "CUR")
    }
    var currencyId :  String
    var isExpense : Bool
    var walletID: String
    var wallet : UserWallet {
        if let _wallet = Resource.sharedInstance().userWallets[walletID] {
            return _wallet
        }
        return UserWallet(id: walletID, name: "Wallet Name", icon: "ꁅ", currencyID: currencyId, creatorID: "", balance: 0.0, totInc: 0.0, totExp: 0.0, creationDate: Date().timeIntervalSince1970, isPersonal: true, memberTypes: [:], isOpen: true, color: textColor.stringRepresentation)
    }
    
    var amountnp : Double {
        return self.isExpense ? -self.amount : self.amount
    }
    
    init(transactionId : String, amount : Double, categoryId : String, comments : String?, date : Double, transactionById : String, currencyId : String, isExpense : Bool, walletID: String) {
        self.id = transactionId
        self.amount = amount
        self.categoryId = categoryId
        self.comments = comments
        self.currencyId = currencyId
        self.date = Date(timeIntervalSince1970: date)
        self.isExpense = isExpense
        self.transactionById = transactionById
        self.walletID = walletID
    }
    func getImage(_ urlS: String, completion : @escaping (Data) -> ()) {
        
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let imageNSURL = url.appendingPathComponent("images/userImages/\(self.id)/\(urlS)")
        if fileManager.fileExists(atPath: imageNSURL.absoluteString) {
            let data = try? Data(contentsOf: imageNSURL)
            completion(data!)
        }else{
            let imageRef = FIRStorage.storage().reference(forURL: "gs://familybudgetapp-6f637.appspot.com").child("images").child("transactionImages").child(self.id).child(urlS)
            imageRef.write(toFile: imageNSURL, completion: { (urlRef, error) in
                guard error == nil else {
                    return
                }
                let data = try! Data(contentsOf: urlRef!)
                completion(data)
            })
        }
    }
    
    
}

class TransactionRequest {
    
    var payee: User {
        if let user = Resource.sharedInstance().users[payeeId]{
            return user
        }
        return User(id: payeeId, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
    }
    var payeeId : String
    var requestID: String
    var transaction: Transaction {
        if let trans = Resource.sharedInstance().transactions[transactionId]{
            return trans
        }
        return Transaction(transactionId: transactionId, amount: 20, categoryId: "", comments: "", date: Date().timeIntervalSince1970, transactionById: transactionId, currencyId: "", isExpense: true, walletID: "")
    }
    var transactionId : String
    var wallet: Wallet {
        if let _wallet = Resource.sharedInstance().userWallets[walletId]{
            return _wallet
        }
        return Wallet(id: walletId, name: "Wallet Name", icon: "ꁅ", creatorID: "", creationDate: Date().timeIntervalSince1970, memberTypes: [:], isOpen: true, color: textColor.stringRepresentation)
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
    func transactionAdded(_ transaction : Transaction)
    func transactionUpdated(_ transaction :  Transaction)
    func transactionDeleted(_ transaction :  Transaction)
}
protocol TransactionRequestDelegate {
    func transactionRequestArrived(_ request : TransactionRequest)
}
