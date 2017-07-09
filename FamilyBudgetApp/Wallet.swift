
import Foundation
import UIKit

enum MemberType {
    case member, admin, owner
}
class Currency {
    var id : String
    var name : String
    var icon : String
    var code: String
    init(id: String, name: String, icon: String, code: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.code = code
    }
    
}

class Category {
    var id: String
    var name: String
    var icon : String
    var color: UIColor
    var isDefault : Bool
    var isExpense : Bool
    init(id: String, name: String, icon: String, isDefault : Bool, isExpense : Bool, color: String) {
        self.icon = icon
        self.name = name
        self.id = id
        self.isDefault = isDefault
        self.isExpense = isExpense
        self.color = UIColor(string: color)
    }
    
}

class Wallet {
    
    var id : String
    var name : String
    var icon : String
    var color : UIColor
    var creator : User {
        if let user = Resource.sharedInstance().users[creatorID]{
            return user
        }
        return User(id: creatorID, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
    }
    var creatorID: String
    var creationDate : Date
    var members : [User] {
        var _members : [User] = []
        for (key,value) in Resource.sharedInstance().users {
            if memberTypes[key] != nil {
                _members.append(value)
            }
        }
        return _members
    }
    var memberTypes :  [String : MemberType]
    var isOpen: Bool
    
    init(id: String, name: String, icon: String, creatorID: String, creationDate: Double, memberTypes: [String: MemberType], isOpen: Bool, color : String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.creatorID = creatorID
        self.creationDate = Date(timeIntervalSince1970 : creationDate)
        self.memberTypes = memberTypes
        self.isOpen = isOpen
        self.color = UIColor(string: color)
    }
    func setIcon(_ iconNo: Int) {
        icon = "\(UnicodeScalar(iconNo))"
    }
    func addMember(_ id : String , type : MemberType){
        if (memberTypes[id] == nil) {
            memberTypes[id] = type
        }
    }
}


class UserWallet : Wallet {
    
    var currencyID: String
    var balance : Double
    var totalExpense : Double
    var totalIncome : Double
    var isPersonal : Bool
    
    var budgetIDs : [String] {
        var budgetIdss : [String] = []
        Resource.sharedInstance().budgets.forEach { (key, budget) in
            if budget.walletID == self.id {
                budgetIdss.append(key)
            }
        }
        return budgetIdss
    }
    var transactionIDs : [String] {
        var transactionIds : [String] = []
        Resource.sharedInstance().transactions.forEach { (key, transaction) in
            if transaction.walletID == self.id {
                transactionIds.append(key)
            }
        }
        return transactionIds
    }
    var taskIDs : [String] {
        var taskIds : [String] = []
        Resource.sharedInstance().tasks.forEach { (key, task) in
            if task.walletID == self.id {
                taskIds.append(key)
            }
        }
        return taskIds
    }
    
    var tasks : [Task] {
        var _tasks : [Task] = []
        for (key,value) in Resource.sharedInstance().tasks {
            if taskIDs.contains(key) {
                _tasks.append(value)
            }
        }
        return _tasks
    }
    var budgets : [Budget]{
        var _budgets : [Budget] = []
        for (key,value) in Resource.sharedInstance().budgets {
            if budgetIDs.contains(key) {
                _budgets.append(value)
            }
        }
        return _budgets
    }
    var transactions : [Transaction]{
        var _transactions : [Transaction] = []
        for (key,value) in Resource.sharedInstance().transactions {
            if transactionIDs.contains(key) {
                _transactions.append(value)
            }
        }
        return _transactions
    }
    var currency : Currency {
        if let _currency = Resource.sharedInstance().currencies[currencyID]{
            return _currency
        }
        return Currency(id: currencyID, name: "Loading...", icon: "ꀕ", code: "CUR")
    }
    
    init(id: String, name: String, icon: String, currencyID: String, creatorID: String, balance: Double, totInc: Double, totExp: Double, creationDate: Double, isPersonal: Bool, memberTypes: [String: MemberType], isOpen: Bool, color : String) {
        self.currencyID = currencyID
        self.balance = balance
        self.totalIncome = totInc
        self.totalExpense = totExp
        self.isPersonal = isPersonal
        super.init(id: id, name: name, icon: icon, creatorID: creatorID, creationDate: creationDate, memberTypes: memberTypes, isOpen: isOpen, color: color)
    }
}
extension UIColor{
    var stringRepresentation : String {
        let color = self.cgColor
        let numComponents = color.numberOfComponents;
        
        if numComponents == 4 {
            let components = color.components;
            let red = components![0]*255;
            let green = components![1]*255;
            let blue = components![2]*255;
            let alpha = components![3];
            return "\(red):\(green):\(blue):\(alpha)"
        }
        return ""
    }
    convenience init(string : String) {

        let comps = string.components(separatedBy: ":")
        if comps.count == 4 {
            self.init(red: CGFloat(Double(comps[0])!)/255, green: CGFloat(Double(comps[1])!)/255, blue: CGFloat(Double(comps[2])!)/255, alpha: CGFloat(Double(comps[3])!))
        }else{
            self.init()
        }
    }
}
protocol WalletDelegate {
    func walletAdded(_ wallet : UserWallet)
    func walletUpdated(_ wallet : UserWallet)
    func WalletDeleted(_ wallet : UserWallet)
}
protocol WalletMemberDelegate {
    func memberAdded(_ member : User, ofType : MemberType, wallet : Wallet)
    func memberLeft(_ member : User,ofType : MemberType, wallet : Wallet)
    func memberUpdated(_ member :  User, ofType : MemberType, wallet : Wallet)
}
protocol WalletCategoryDelegate {
    func categoryAdded(_ category: Category, wallet : Wallet)
    func categoryUpdated(_ category: Category, wallet : Wallet)
    func categoryRemoved(_ category: Category, wallet : Wallet)
}



