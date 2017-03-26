import Foundation
import Firebase

class HelperObservers  {
    fileprivate let FIRKeys = ["DefaultCategories", //0
        "name", //1
        "icon", //2
        "Currencies", //3
        "code"] //4
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate static var singleInstance : HelperObservers?
    class func sharedInstance() -> HelperObservers {
        guard let instance = HelperObservers.singleInstance else {
            HelperObservers.singleInstance = HelperObservers()
            return singleInstance!
        }
        return instance
    }
    func startObserving(){
        observeCategoryAdded()
        observeCategoryUpdated()
        observeCategoryDeleted()
        observeCurrencyAdded()
        observeCurrencyUpdated()
        observeCurrencyRemoved()
    }
    func stopObserving(){
        FIRDatabase.database().reference().child("DefaultCategories").removeAllObservers()
        FIRDatabase.database().reference().child("Currencies").removeAllObservers()
    }
    
    func getUserAndWallet(_ callback : ((_ success : Bool) -> Void)?){
        
        
        var flag1 = false , flag2 = false
        if (Resource.sharedInstance().currentUser != nil) && (Resource.sharedInstance().currentWallet != nil) {
            flag1 = true
            flag2 = true
            callback?(true)
            return
        }
        
        FIRDatabase.database().reference().child("Users").child(Resource.sharedInstance().currentUserId!).observeSingleEvent(of: .value, with: { (snap) in
            if let data = snap.value as? NSDictionary {
                let newUser = CurrentUser(id: Resource.sharedInstance().currentUserId!, email: data["email"] as! String, userName: data["userName"] as! String, imageURL: data["image"] as! String, birthdate: data["birthDate"] as? Double, deviceID: nil, gender: data["gender"] as! Int)
                Resource.sharedInstance().users[newUser.getUserID()] = newUser
                Delegate.sharedInstance().getUserDelegates().forEach({ (userDel) in
                    userDel.userAdded(newUser)
                })
                flag1 = true
                if flag2 {
                    callback?(true)
                }
            }else{
                callback?(false)
            }
        })
        
        //for getting the wallet which is to be shown
        print(Resource.sharedInstance().currentWalletID)
        FIRDatabase.database().reference().child("Wallets").child(Resource.sharedInstance().currentWalletID!).observeSingleEvent(of: FIRDataEventType.value, with: { (snap) in
            guard let dict = snap.value as? [String: Any] else {
                print("Wallet value isnt a dictionary \(snap.key)")
                callback?(false)
                return
            }
            let wallet = UserWallet(id: snap.key,
                                    name: dict["name"] as! String, icon: dict["icon"] as! String, currencyID: dict["currency"] as! String, creatorID: dict["creator"] as! String, balance: dict["balance"] as! Double, totInc: dict["totIncome"] as! Double, totExp: dict["totExpense"] as! Double, creationDate: dict["creationDate"] as! Double, isPersonal: dict["isPersonal"] as! Bool, memberTypes: [:], isOpen: dict["isOpen"] as! Bool, color: dict["color"] as! String)
            Resource.sharedInstance().userWallets[snap.key] = wallet
            Delegate.sharedInstance().getWalletDelegates().forEach({ (walletDel) in
                walletDel.walletAdded(wallet)
            })
            flag2 = true
            if flag1 {
                callback?(true)
            }
            //All Requirements to proceed accomplished
        })
    }
    
    fileprivate func observeCategoryAdded(){
        let catgoryRef = ref.child(FIRKeys[0])
        catgoryRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else {
                return
            }
            let category = Category(id: snapshot.key, name: dict[self.FIRKeys[1]] as! String, icon: dict[self.FIRKeys[2]] as! String, isDefault: true, isExpense: dict["isExpense"] as! Bool, color: dict["color"] as! String)
            Resource.sharedInstance().categories[snapshot.key] = category
            Delegate.sharedInstance().getCategoryDelegates().forEach({ (catDel) in
                catDel.categoryAdded(category)
            })
        })
    }
    fileprivate func observeCategoryUpdated(){
        let catgoryRef = ref.child(FIRKeys[0])
        catgoryRef.observe(FIRDataEventType.childChanged, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let category = Category(id: snapshot.key, name: dict[self.FIRKeys[1]] as! String, icon: dict[self.FIRKeys[2]] as! String, isDefault: true, isExpense: dict["isExpense"] as! Bool, color: dict["color"] as! String)
            Resource.sharedInstance().categories[snapshot.key] = category
            Delegate.sharedInstance().getCategoryDelegates().forEach({ (catDel) in
                catDel.categoryUpdated(category)
            })
        })
    }
    fileprivate func observeCategoryDeleted(){
        let catgoryRef = ref.child(FIRKeys[0])
        catgoryRef.observe(FIRDataEventType.childRemoved, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let category = Category(id: snapshot.key, name: dict[self.FIRKeys[1]] as! String, icon: dict[self.FIRKeys[2]] as! String, isDefault: true, isExpense: dict["isExpense"] as! Bool, color: dict["color"] as! String)
            Resource.sharedInstance().categories[snapshot.key] = nil
            Delegate.sharedInstance().getCategoryDelegates().forEach({ (catDel) in
                catDel.categoryDeleted(category)
            })
        })
    }
    
    fileprivate func observeCurrencyAdded(){
        let currencyRef = ref.child(FIRKeys[3])
        currencyRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let currency = Currency(id: snapshot.key, name: dict[self.FIRKeys[1]] as! String, icon: dict[self.FIRKeys[2]] as! String, code: dict[self.FIRKeys[4]] as! String)
            Resource.sharedInstance().currencies[snapshot.key] = currency
            Delegate.sharedInstance().getCurrencyDelegates().forEach({ (catDel) in
                catDel.currencyAdded(currency)
            })
        })
    }
    fileprivate func observeCurrencyUpdated(){
        let currencyRef = ref.child(FIRKeys[3])
        currencyRef.observe(FIRDataEventType.childChanged, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else  {
                return
            }
            let currency = Currency(id: snapshot.key, name: dict[self.FIRKeys[1]] as! String, icon: dict[self.FIRKeys[2]] as! String, code: dict[self.FIRKeys[4]] as! String)
            Resource.sharedInstance().currencies[snapshot.key] = currency
            Delegate.sharedInstance().getCurrencyDelegates().forEach({ (curDel) in
                curDel.currencyUpdated(currency)
            })
        })
    }
    fileprivate func observeCurrencyRemoved(){
        let currencyRef = ref.child(FIRKeys[3])
        currencyRef.observe(FIRDataEventType.childRemoved, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let currency = Currency(id: snapshot.key, name: dict[self.FIRKeys[1]] as! String, icon: dict[self.FIRKeys[2]] as! String, code: dict[self.FIRKeys[4]] as! String)
            Resource.sharedInstance().currencies[snapshot.key] = nil
            Delegate.sharedInstance().getCurrencyDelegates().forEach({ (curDel) in
                curDel.currencyDeleted(currency)
            })
        })
    }
    
}

protocol CategoryDelegate {
    func categoryAdded(_ category : Category)
    func categoryUpdated(_ category : Category)
    func categoryDeleted(_ category : Category)
}
protocol CurrencyDelegate {
    func currencyAdded(_ currency : Currency)
    func currencyUpdated(_ currency : Currency)
    func currencyDeleted(_ currency : Currency)
}
