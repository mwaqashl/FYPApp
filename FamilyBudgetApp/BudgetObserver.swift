import Foundation
import Firebase

class BudgetObserver {
    fileprivate let FIRKeys = ["Budgets", //0
                           "BudgetMembers", //1
                           "BudgetCategories", //2
                           "allocAmount", //3
                           "title", //4
                           "period", //5
                           "comments", //6
                           "isOpen", //7
                           "walletID", // 8
                           "startDate"] //9
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate static var singleInstance : BudgetObserver?
    class func sharedInstance() -> BudgetObserver {
        guard let instance = BudgetObserver.singleInstance else {
            BudgetObserver.singleInstance = BudgetObserver()
            return singleInstance!
        }
        return instance
    }
    fileprivate var _autoObserve : Bool = true
    fileprivate var isObservingBudgetsOf : [String] = []
    var autoObserve : Bool {
        get { return _autoObserve } set {
            if newValue {
                Resource.sharedInstance().budgets.forEach({ (key, budget) in
                BudgetObserver.sharedInstance().startObservingBudget(budget)
            })
            }else{
                Resource.sharedInstance().budgets.forEach({ (key, budget) in
                    BudgetObserver.sharedInstance().stopObservingBudget(budget)
                })
            }
            _autoObserve = newValue
        }
    }
    func startObserving(BudgetsOf wallet : UserWallet){
        if !isObservingBudgetsOf.contains(wallet.id){
            observeBudget(AddedOf : wallet)
            observeBudget(DeletedOf : wallet)
            observeBudget(UpdatedOf : wallet)
            isObservingBudgetsOf.append(wallet.id)
        }
    }
    func startObservingBudget(_ budget : Budget){
        stopObservingBudget(budget)
        observeBudgetMemberAdded(budget);
        observeBudgetMemberUpdated(budget);
        observeBudgetMemberRemoved(budget);
        observeBudgetCategoryAdded(budget);
        observeBudgetCategoryUpdated(budget);
        observeBudgetCategoryRemoved(budget);
    }
    func stopObservingBudget(_ budget :  Budget){
        FIRDatabase.database().reference().child(FIRKeys[1]).child(budget.id).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[2]).child(budget.id).removeAllObservers()
    }
    func stopObserving(BudgetsOf wallet : UserWallet){
        FIRDatabase.database().reference().child(FIRKeys[0]).child(wallet.id).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[1]).child(wallet.id).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[2]).child(wallet.id).removeAllObservers()
        if isObservingBudgetsOf.contains(wallet.id){
            isObservingBudgetsOf.remove(at: isObservingBudgetsOf.index(of: wallet.id)!)
        }
    }
    fileprivate func observeBudget(AddedOf wallet : UserWallet){
        let budgetRef = ref.child(FIRKeys[0]).child(wallet.id)
        budgetRef.observe(FIRDataEventType.childAdded, with:  { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let budget = Budget(budgetId: snapshot.key, allocAmount: dict[self.FIRKeys[3]] as! Double,  title: dict[self.FIRKeys[4]] as! String, period: dict[self.FIRKeys[5]] as! Int, startDate : (dict[self.FIRKeys[9]] as! Double)/1000, comments: dict[self.FIRKeys[6]] as? String, isOpen: dict[self.FIRKeys[7]] as! Bool, categoryIDs: [], memberIDs: [], walletID: dict[self.FIRKeys[8]] as! String)
            Resource.sharedInstance().budgets[snapshot.key] = budget
            if self.autoObserve { self.observeBudgetMemberAdded(budget); self.observeBudgetMemberUpdated(budget); self.observeBudgetMemberRemoved(budget);
                self.observeBudgetCategoryAdded(budget); self.observeBudgetCategoryUpdated(budget); self.observeBudgetCategoryRemoved(budget); }
            Delegate.sharedInstance().getBudgetDelegates().forEach({ (budgetDel) in
                budgetDel.budgetAdded(budget)
            })
        })
    }
    fileprivate func observeBudget(UpdatedOf wallet : UserWallet){
        let budgetRef = ref.child(FIRKeys[0]).child(wallet.id)
        budgetRef.observe(FIRDataEventType.childChanged, with:  { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let budget = Resource.sharedInstance().budgets[snapshot.key]!
            budget.title = dict[self.FIRKeys[4]] as! String
            budget.allocAmount = dict[self.FIRKeys[3]] as! Double
            budget.period = dict[self.FIRKeys[5]] as! Int
            budget.comments = dict[self.FIRKeys[6]] as? String
            budget.isOpen = dict[self.FIRKeys[7]] as! Bool
            Resource.sharedInstance().budgets[snapshot.key] = budget
            Delegate.sharedInstance().getBudgetDelegates().forEach({ (budgetDel) in
                budgetDel.budgetUpdated(budget)
            })
        })
    }
    fileprivate func observeBudget(DeletedOf wallet : UserWallet){
        let budgetRef = ref.child(FIRKeys[0]).child(wallet.id)
        budgetRef.observe(FIRDataEventType.childRemoved, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            guard let budget = Resource.sharedInstance().budgets[snapshot.key]  else {
                return
            }
            self.stopObservingBudget(budget)
            Resource.sharedInstance().budgets[snapshot.key] = nil
            Delegate.sharedInstance().getBudgetDelegates().forEach({ (budgetDel) in
                budgetDel.budgetDeleted(budget)
            })
        })
    }
    fileprivate func observeBudgetMemberAdded(_ budget: Budget){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let budgetRef = ref.child(FIRKeys[1]).child(budget.id)
        budgetRef.observe(FIRDataEventType.childAdded, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if snapshot.value as! Bool { Resource.sharedInstance().budgets[budget.id]?.addMember(snapshot.key) }
            Delegate.sharedInstance().getBudgetMemberDelegates().forEach({ (budgetMemDel) in
                if let user = Resource.sharedInstance().users[snapshot.key] {
                    budgetMemDel.memberAdded(user, budget: budget)
                }else{
                    let user = User(id: snapshot.key, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
                    budgetMemDel.memberAdded(user, budget: budget)
                }
            })
        })
    }
    fileprivate func observeBudgetMemberUpdated(_ budget: Budget){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let budgetRef = ref.child(FIRKeys[1]).child(budget.id)
        budgetRef.observe(FIRDataEventType.childChanged, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if snapshot.value as! Bool {
                Resource.sharedInstance().budgets[budget.id]?.addMember(snapshot.key)
                Delegate.sharedInstance().getBudgetMemberDelegates().forEach({ (budgetMemDel) in
                    if let user = Resource.sharedInstance().users[snapshot.key] {
                        budgetMemDel.memberAdded(user, budget: budget)
                    }else{
                        let user = User(id: snapshot.key, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
                        budgetMemDel.memberAdded(user, budget: budget)
                    }
                })
            }else{
                Resource.sharedInstance().budgets[budget.id]?.removeMember(snapshot.key)
                Delegate.sharedInstance().getBudgetMemberDelegates().forEach({ (budgetMemDel) in
                    if let user = Resource.sharedInstance().users[snapshot.key] {
                        budgetMemDel.memberLeft(user, budget: budget)
                    }else{
                        let user = User(id: snapshot.key, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
                        budgetMemDel.memberLeft(user, budget: budget)
                    }
                })
            }
            
        })
    }
    fileprivate func observeBudgetMemberRemoved(_ budget: Budget){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let budgetRef = ref.child(FIRKeys[1]).child(budget.id)
        budgetRef.observe(FIRDataEventType.childRemoved, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().budgets[budget.id]?.removeMember(snapshot.key)
            Delegate.sharedInstance().getBudgetMemberDelegates().forEach({ (budgetMemDel) in
                if let user = Resource.sharedInstance().users[snapshot.key] {
                    budgetMemDel.memberLeft(user, budget: budget)
                }else{
                    let user = User(id: snapshot.key, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
                    budgetMemDel.memberLeft(user, budget: budget)
                }
            })
        })
    }
    fileprivate func observeBudgetCategoryAdded(_ budget : Budget){
        let budgetRef = ref.child(FIRKeys[2]).child(budget.id)
        budgetRef.observe(FIRDataEventType.childAdded, with:  { (snapshot) in
            guard (snapshot.value) != nil else {
                return
            }
            if !(snapshot.value as! Bool) {return}
            Resource.sharedInstance().budgets[budget.id]?.addCategory(snapshot.key)
            Delegate.sharedInstance().getBudgetCategoryDelegates().forEach({ (budgetCatDel) in
                if let category = Resource.sharedInstance().categories[snapshot.key] {
                    budgetCatDel.categoryAdded(category, budget: budget)
                }else{
                    let category = Category(id: snapshot.key, name: "Loading...", icon: "ꀔ", isDefault: true, isExpense: true, color: textColor.stringRepresentation)
                    budgetCatDel.categoryAdded(category, budget: budget)
                }
            })
        })
    }
    fileprivate func observeBudgetCategoryUpdated(_ budget : Budget){
        let budgetRef = ref.child(FIRKeys[2]).child(budget.id)
        budgetRef.observe(FIRDataEventType.childChanged, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if snapshot.value as! Bool {
                Resource.sharedInstance().budgets[budget.id]?.addCategory(snapshot.key)
                Delegate.sharedInstance().getBudgetCategoryDelegates().forEach({ (budgetCatDel) in
                    if let category = Resource.sharedInstance().categories[snapshot.key] {
                        budgetCatDel.categoryAdded(category, budget: budget)
                    }else{
                        let category = Category(id: snapshot.key, name: "Loading...", icon: "ꀔ", isDefault: true, isExpense: true, color: textColor.stringRepresentation)
                        budgetCatDel.categoryAdded(category, budget: budget)
                    }
                })
            }else{
                Resource.sharedInstance().budgets[budget.id]?.removeCategory(snapshot.key)
                Delegate.sharedInstance().getBudgetCategoryDelegates().forEach({ (budgetCatDel) in
                    if let category = Resource.sharedInstance().categories[snapshot.key] {
                        budgetCatDel.categoryRemoved(category, budget: budget)
                    }else{
                        let category = Category(id: snapshot.key, name: "Loading...", icon: "ꀔ", isDefault: true, isExpense: true, color: textColor.stringRepresentation)
                        budgetCatDel.categoryRemoved(category, budget: budget)
                    }
                })
            }
        })
    }
    fileprivate func observeBudgetCategoryRemoved(_ budget : Budget){
        let budgetRef = ref.child(FIRKeys[2]).child(budget.id)
        budgetRef.observe(FIRDataEventType.childRemoved, with:  { (snapshot) in
            guard (snapshot.value) != nil else {
                return
            }
            Resource.sharedInstance().budgets[budget.id]?.removeCategory(snapshot.key)
            Delegate.sharedInstance().getBudgetCategoryDelegates().forEach({ (budgetCatDel) in
                if let category = Resource.sharedInstance().categories[snapshot.key] {
                    budgetCatDel.categoryRemoved(category, budget: budget)
                }else{
                    let category = Category(id: snapshot.key, name: "Loading...", icon: "ꀔ", isDefault: true, isExpense: true, color: textColor.stringRepresentation)
                    budgetCatDel.categoryRemoved(category, budget: budget)
                }
            })
        })
    }
}
