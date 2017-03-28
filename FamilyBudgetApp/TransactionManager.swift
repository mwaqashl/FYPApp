
import Foundation
import Firebase

class TransactionManager {
    
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate static var singleTonInstance = TransactionManager()
    
    static func sharedInstance() -> TransactionManager {
        return singleTonInstance
    }
    
    /**
     Add a new transaction
     Call this method when a new transaction is perform in a wallet
     
     
     :param: Newly made Transaction
     
     */
    func AddTransactionInWallet(_ transaction: Transaction) {
        
        let transRef = ref.child("Transactions/\(transaction.walletID)").childByAutoId()
        
        let data : NSMutableDictionary = [
            "amount":transaction.amount,
            "categoryID":transaction.categoryId,
            "date":transaction.date.timeIntervalSince1970*1000,
            "transactionBy": transaction.transactionById,
            "currency": transaction.currencyId,
            "isExpense": transaction.isExpense
        ]
        
        if transaction.comments != nil {
            data["comments"] = transaction.comments
        }
        
        transRef.setValue(data)
        transaction.id = transRef.key
        updateWalletFromTransaction(transaction)
        
    }
    
    /**
     Update Wallet From transaction.
     perform the required changes to wallet which occurs due to transaction in a wallet
     
     :param: Transaction object
     
     */
    fileprivate func updateWalletFromTransaction(_ transaction: Transaction) {
        
        let walletRef = ref.child("Wallets/\(transaction.walletID)")
        
        walletRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var walletData = currentData.value as? [String : Any] {
                print(walletData["balance"])
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
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)

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
    func updateTransactionInWallet(_ transaction: Transaction) {
        
        let transRef = ref.child("Transactions/\(transaction.walletID)/\(transaction.id)")
        
        if let oldTrans = Resource.sharedInstance().transactions[transaction.id] {
            
            if oldTrans.amount == transaction.amount {
                
                var data : [String:Any] = [
                    "amount":transaction.amount,
                    "categoryID":transaction.categoryId,
                    "date":transaction.date.timeIntervalSince1970*1000,
                    "currency": transaction.currencyId,
                    "isExpense": transaction.isExpense
                ]
                
                if transaction.comments != nil {
                    data["comments"] = transaction.comments
                }
                                
                transRef.updateChildValues(data)
                
            }
            else {
                
                transRef.runTransactionBlock({ (currentData) -> FIRTransactionResult in
                    
                    if var walletData = currentData.value as? [String:Any] {
                        
                        walletData["amount"] = transaction.amount
                        walletData["categoryID"] = transaction.categoryId
                        walletData["date"] = transaction.date.timeIntervalSince1970*1000
                        walletData["currency"] = transaction.currencyId
                        walletData["isExpense"] = transaction.isExpense
                        
                        if transaction.comments != nil {
                            walletData["comments"] = transaction.comments
                        }
                        
                        var balance = walletData["balance"] as! Double
                        var totExp = walletData["totExpense"] as! Double
                        var totInc = walletData["totIncome"] as! Double
                        
                        balance -= oldTrans.amountnp
                        balance += transaction.amountnp
                        if oldTrans.isExpense && transaction.isExpense {
                            totExp += transaction.amountnp - oldTrans.amountnp
                        }
                        else if !oldTrans.isExpense && transaction.isExpense {
                            totInc -= oldTrans.amount
                            totExp += transaction.amount
                        }
                        else if oldTrans.isExpense && !transaction.isExpense {
                            totExp -= oldTrans.amount
                            totInc += transaction.amount
                        }
                        else {
                            totInc += transaction.amountnp - oldTrans.amountnp
                        }
                        
                        walletData["balance"] = balance
                        walletData["totIncome"] = totInc
                        walletData["totExpense"] = totExp
                        
                        return FIRTransactionResult.success(withValue: currentData)
                    }
                    
                    return FIRTransactionResult.success(withValue: currentData)
                    
                }, andCompletionBlock: { (error, commit, data) in
                    
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                    
                })
                
            }
            
        }
        
        
        
    }
    
    /**
     Undo a transaction from wallet
     Deletes the transaction from database and perfrorm required changes in wallet !
     
     */
    func removeTransactionInWallet(_ transaction: Transaction, wallet: UserWallet) {
        ref.child("Transactions/\(wallet.id)/\(transaction.id)").removeValue()
        
        ref.child("Wallets").child(wallet.id).runTransactionBlock { (currentData) -> FIRTransactionResult in
            
            if var walletData = currentData.value as? [String:Any] {
                
                if transaction.isExpense {
                    walletData["balance"] = wallet.balance + transaction.amount
                    walletData["totExpense"] = wallet.totalExpense - transaction.amount
                }
                else {
                    walletData["balance"] = wallet.balance - transaction.amount
                    walletData["totIncome"] = wallet.totalIncome - transaction.amount
                }
                
                currentData.value = walletData
                return FIRTransactionResult.success(withValue: currentData)
            }
            
            return FIRTransactionResult.success(withValue: currentData)
        }
        
    }
    
    // Working !
    func requestTransaction(_ request: TransactionRequest) {
        
        let reqRef = ref.child("TransactionRequests").child(request.payeeId).childByAutoId()
        
        reqRef.setValue(["transactionID":request.transactionId,"walletID":request.walletId])
        
    }
    
    func removeRequestTransaction(_ request: TransactionRequest) {
        
        ref.child("TransactionRequests").child(request.payeeId).child(request.requestID).removeValue()
    }
    
}
