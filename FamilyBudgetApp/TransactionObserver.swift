
import Foundation
import Firebase

class TransactionObserver {
    fileprivate let FIRKeys = ["Transactions", //0
        "walletID", //1
        "transactionID", //2
        "amount", //3
        "categoryID", //4
        "comments", //5
        "transactionBy", //6
        "currency", //7
        "isExpense", //8
        "date"] //9
    
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate static var singleInstance : TransactionObserver?
    fileprivate var isObservingTransactionsOf : [String] = []
    class func sharedInstance() -> TransactionObserver {
        guard let instance = TransactionObserver.singleInstance else {
            TransactionObserver.singleInstance = TransactionObserver()
            return singleInstance!
        }
        return instance
    }
    func startObservingTransaction(ofWallet walletId : String){
        if !isObservingTransactionsOf.contains(walletId){
            observeTransactionAdded(walletId)
            observeTransactionUpdated(walletId)
            observeTransactionDeleted(walletId)
            isObservingTransactionsOf.append(walletId)
        }
    }
    func stopObservingTransaction(ofWallet wallet : String){
        FIRDatabase.database().reference().child(FIRKeys[0]).child(wallet).removeAllObservers()
        if isObservingTransactionsOf.contains(wallet){
            isObservingTransactionsOf.remove(at: isObservingTransactionsOf.index(of: wallet)!)
        }
    }
    fileprivate func observeTransactionAdded(_ wallet: String) {
        let transactionRef = ref.child(FIRKeys[0]).child(wallet)
        transactionRef.observe(FIRDataEventType.childAdded, with: {(snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let transaction = Transaction(transactionId: snapshot.key,
                amount: dict[self.FIRKeys[3]] as! Double,
                categoryId: dict[self.FIRKeys[4]] as! String,
                comments: dict[self.FIRKeys[5]] as? String,
                date: (dict[self.FIRKeys[9]] as! Double)/1000,
                transactionById: dict[self.FIRKeys[6]] as! String,
                currencyId: dict[self.FIRKeys[7]] as! String,
                isExpense: dict[self.FIRKeys[8]] as! Bool,
                walletID: wallet)
            Resource.sharedInstance().transactions[snapshot.key] = transaction
            Delegate.sharedInstance().getTransactionDelegates().forEach({ (transactionDel) in
                transactionDel.transactionAdded(transaction)
            })
        })
        
    }
    fileprivate func observeTransactionUpdated(_ wallet: String) {
        let transactionRef = ref.child(FIRKeys[0]).child(wallet)
        transactionRef.observe(FIRDataEventType.childChanged, with: {(snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            let transaction = Resource.sharedInstance().transactions[snapshot.key]!
            transaction.amount = dict[self.FIRKeys[3]] as! Double
            transaction.categoryId = dict[self.FIRKeys[4]] as! String
            transaction.comments = dict[self.FIRKeys[5]] as? String
            transaction.currencyId = dict[self.FIRKeys[7]] as! String
            transaction.isExpense = dict[self.FIRKeys[8]] as! Bool
            Resource.sharedInstance().transactions[snapshot.key] = transaction
            Delegate.sharedInstance().getTransactionDelegates().forEach({ (transactionDel) in
                transactionDel.transactionUpdated(transaction)
            })
        })
        
    }
    fileprivate func observeTransactionDeleted(_ wallet: String) {
        let transactionRef = ref.child(FIRKeys[0]).child(wallet)
        transactionRef.observe(FIRDataEventType.childRemoved, with: {(snapshot) in
            guard (snapshot.value as? NSDictionary) != nil else {
                return
            }
            let transaction = Resource.sharedInstance().transactions[snapshot.key]!
            Resource.sharedInstance().transactions[snapshot.key] = nil
            Delegate.sharedInstance().getTransactionDelegates().forEach({ (transactionDel) in
                transactionDel.transactionDeleted(transaction)
            })
        })
    }
}
