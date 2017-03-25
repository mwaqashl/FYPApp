

import Foundation
import Firebase

class WalletObserver {
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate var isObservingWallets = false
    fileprivate var isObservingWallet : [String: Bool] = [:]
    
    fileprivate var _autoObserve : Bool = true
    var autoObserve : Bool {
        get { return _autoObserve } set {
            if newValue {
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().startObserving(PartsOf : wallet)
                })
            }else{
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().stopObserving(PartsOf : wallet)
                })
            }
            _autoObserve = newValue
        }
    }
    fileprivate var _autoObserveTransactions : Bool = true
    var autoObserveTransactions : Bool {
        get { return _autoObserveTransactions } set {
            if newValue {
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().startObserving(TransactionsOf : wallet)
                })
            }else{
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().stopObserving(TransactionsOf : wallet)
                })
            }
            _autoObserveTransactions = newValue
        }
    }
    fileprivate var _autoObserveBudgets : Bool = true
    var autoObserveBudgets : Bool {
        get { return _autoObserveBudgets } set {
            if newValue {
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().startObserving(BudgetsOf : wallet)
                })
            }else{
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().stopObserving(BudgetsOf : wallet)
                })
            }
            _autoObserveTransactions = newValue
        }
    }
    fileprivate var _autoObserveTasks : Bool = true
    var autoObserveTasks : Bool {
        get { return _autoObserveTasks } set {
            if newValue {
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().startObserving(TasksOf : wallet)
                })
            }else{
                Resource.sharedInstance().userWallets.forEach({ (key, wallet) in
                    WalletObserver.sharedInstance().stopObserving(TasksOf : wallet)
                })
            }
            _autoObserveTransactions = newValue
        }
    }
    
    fileprivate static var singleInstance : WalletObserver?
    class func sharedInstance() -> WalletObserver {
        guard let instance = WalletObserver.singleInstance else {
            WalletObserver.singleInstance = WalletObserver()
            return singleInstance!
        }
        return instance
    }
    
    func startObserving(){
        if !isObservingWallets {
            observeWalletAdded()
            observeWalletDeleted()
            isObservingWallets = true
        }
    }
    func stopObserving(){
        FIRDatabase.database().reference().child("UserWallets").removeAllObservers()
        FIRDatabase.database().reference().child("Wallets").removeAllObservers()
        FIRDatabase.database().reference().child("WalletMembers").removeAllObservers()
        FIRDatabase.database().reference().child("WalletCategories").removeAllObservers()
    }
    
    func startObserving(PartsOf wallet :  UserWallet){
        if let flag = isObservingWallet[wallet.id], flag {
            return
        }
        observeWalletMemberAdded(wallet);
        observeWalletMemberUpdated(wallet);
        observeWalletMemberRemoved(wallet);
        isObservingWallet[wallet.id] = true
    }
    func stopObserving(PartsOf wallet :  UserWallet){
        if let flag = isObservingWallet[wallet.id] , flag {
            FIRDatabase.database().reference().child("WalletMembers").child(wallet.id).removeAllObservers()
            FIRDatabase.database().reference().child("WalletCategories").child(wallet.id).removeAllObservers()
            isObservingWallet[wallet.id] = false
        }
    }
    
    func startObserving(TransactionsOf Wallet: UserWallet){
        TransactionObserver.sharedInstance().startObservingTransaction(ofWallet: Wallet.id)
    }
    func stopObserving(TransactionsOf Wallet : UserWallet){
        TransactionObserver.sharedInstance().stopObservingTransaction(ofWallet: Wallet.id)
    }
    
    func startObserving(BudgetsOf Wallet : UserWallet){
        BudgetObserver.sharedInstance().startObserving(BudgetsOf: Wallet)
    }
    func stopObserving(BudgetsOf Wallet : UserWallet){
        BudgetObserver.sharedInstance().stopObserving(BudgetsOf: Wallet)
    }
    
    func startObserving(TasksOf Wallet : UserWallet){
        
    }
    func stopObserving(TasksOf Wallet : UserWallet){
        
    }
    
    fileprivate func observeWalletAdded(){
        //print(Resource.sharedInstance().currentUserId)
        let walletsRef = ref.child("UserWallets").child(Resource.sharedInstance().currentUserId!)
        walletsRef.observe(FIRDataEventType.childAdded, with:  { (snapshot) in
            let walletRef = self.ref.child("Wallets").child(snapshot.key)
            walletRef.observe(FIRDataEventType.value, with: { (snapshot1) in
                guard let dict = snapshot1.value as? [String: Any] else {
                    print("Wallet value isnt a dictionary \(snapshot.key)")
                    return
                }
                if Resource.sharedInstance().userWallets[snapshot1.key] != nil {
                    let wallet = Resource.sharedInstance().userWallets[snapshot.key]!
                    wallet.name = dict["name"] as! String
                    wallet.icon = dict["icon"] as! String
                    wallet.currencyID = dict["currency"] as! String
                    wallet.creatorID = dict["creator"] as! String
                    wallet.balance = dict["balance"] as! Double
                    wallet.totalIncome = dict["totIncome"] as! Double
                    wallet.totalExpense = dict["totExpense"] as! Double
                    wallet.creationDate = Date(timeIntervalSince1970 : (dict["creationDate"] as! Double)/1000)
                    wallet.isPersonal = dict["isPersonal"] as! Bool
                    wallet.isOpen = dict["isOpen"] as! Bool
                    wallet.color = UIColor(string: dict["color"] as! String)
                    Resource.sharedInstance().userWallets[snapshot1.key] = wallet
                    Delegate.sharedInstance().getWalletDelegates().forEach({ (walletDel) in
                        walletDel.walletUpdated(wallet)
                    })
                }else{
                    let wallet = UserWallet(id: snapshot1.key,
                                            name: dict["name"] as! String, icon: dict["icon"] as! String, currencyID: dict["currency"] as! String, creatorID: dict["creator"] as! String, balance: dict["balance"] as! Double, totInc: dict["totIncome"] as! Double, totExp: dict["totExpense"] as! Double, creationDate: (dict["creationDate"] as! Double)/1000, isPersonal: dict["isPersonal"] as! Bool, memberTypes: [:], isOpen: dict["isOpen"] as! Bool, color: dict["color"] as! String)
                    Resource.sharedInstance().userWallets[snapshot1.key] = wallet
                    print("Printing dict : \(dict)\n\(dict["balance"])\n")
                    print("Printing Wallet : \(wallet.creator.userName)\n\(wallet.balance)")
                    if self.autoObserve { self.startObserving(PartsOf : wallet) }
                    if self.autoObserveTransactions { self.startObserving(TransactionsOf : wallet) }
                    if self.autoObserveTasks { self.startObserving(TasksOf: wallet) }
                    if self.autoObserveBudgets { self.startObserving(BudgetsOf: wallet) }
                    
                    Delegate.sharedInstance().getWalletDelegates().forEach({ (walletDel) in
                        walletDel.walletAdded(wallet)
                    })
                }
                
            })
        })
    }
    fileprivate func observeWalletDeleted(){
        let walletsRef = ref.child("UserWallets").child(Resource.sharedInstance().currentUserId!)
        walletsRef.observe(FIRDataEventType.childRemoved, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            guard let wallet = Resource.sharedInstance().userWallets[snapshot.key]  else {
                return
            }
            self.stopObserving(PartsOf : wallet)
            self.stopObserving(TasksOf: wallet)
            self.startObserving(BudgetsOf: wallet)
            self.stopObserving(TransactionsOf: wallet)
            Resource.sharedInstance().userWallets[snapshot.key] = nil
            Delegate.sharedInstance().getWalletDelegates().forEach({ (walletDel) in
                walletDel.WalletDeleted(wallet)
            })
        })
    }
    fileprivate func observeWalletMemberAdded(_ wallet: Wallet){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let walletRef = ref.child("WalletMembers").child(wallet.id)
        walletRef.observe(FIRDataEventType.childAdded, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().userWallets[wallet.id]?.addMember(snapshot.key, type: helperFunctions.getMemberType(snapshot.value as! Int))
            Delegate.sharedInstance().getWalletMemberDelegates().forEach({ (walletMemDel) in
                if let user = Resource.sharedInstance().users[snapshot.key] {
                    walletMemDel.memberAdded(user, ofType : helperFunctions.getMemberType(snapshot.value as! Int), wallet: wallet)
                }else{
                    let user = User(id: snapshot.key, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
                    walletMemDel.memberAdded(user, ofType : helperFunctions.getMemberType(snapshot.value as! Int), wallet: wallet)
                }
            })
        })
    }
    fileprivate func observeWalletMemberUpdated(_ wallet: Wallet){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let walletRef = ref.child("WalletMembers").child(wallet.id)
        walletRef.observe(FIRDataEventType.childChanged, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().userWallets[wallet.id]?.memberTypes[snapshot.key] = helperFunctions.getMemberType(snapshot.value as! Int)
            Delegate.sharedInstance().getWalletMemberDelegates().forEach({ (walletMemDel) in
                if let user = Resource.sharedInstance().users[snapshot.key] {
                    walletMemDel.memberUpdated(user, ofType : helperFunctions.getMemberType(snapshot.value as! Int), wallet: wallet)
                }else{
                    let user = User(id: snapshot.key, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
                    walletMemDel.memberUpdated(user, ofType : helperFunctions.getMemberType(snapshot.value as! Int), wallet: wallet)
                }
            })
        })
    }
    fileprivate func observeWalletMemberRemoved(_ wallet: Wallet){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let walletRef = ref.child("WalletMembers").child(wallet.id)
        walletRef.observe(FIRDataEventType.childRemoved, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().userWallets[wallet.id]?.memberTypes[snapshot.key] = nil
            Delegate.sharedInstance().getWalletMemberDelegates().forEach({ (walletMemDel) in
                if let user = Resource.sharedInstance().users[snapshot.key] {
                    walletMemDel.memberLeft(user, ofType : helperFunctions.getMemberType(snapshot.value as! Int), wallet: wallet)
                }else{
                    let user = User(id: snapshot.key, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
                    walletMemDel.memberLeft(user, ofType : helperFunctions.getMemberType(snapshot.value as! Int), wallet: wallet)
                }
            })
            
        })
    }
    
    
}
