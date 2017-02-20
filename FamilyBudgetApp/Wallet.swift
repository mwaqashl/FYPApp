//
//  Wallet.swift
//  AccBook
//
//  Created by MacUser on 8/16/16.
//  Copyright © 2016 Collage. All rights reserved.
//

import Foundation

enum MemberType {
    case Member, Admin, Owner
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
    var isTravel = false
    var creator : User? // computed
    var creatorID: String
    var creationDate : NSDate
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
        self.creationDate = NSDate(timeIntervalSince1970 : creationDate/1000)
        self.memberTypes = memberTypes
        self.isOpen = isOpen
        self.color = UIColor(string: color)
    }
    func setIcon(iconNo: Int) {
        icon = "\(UnicodeScalar(iconNo))"
    }
    func addMember(id : String , type : MemberType){
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
    private var categoryIDs: [String]
    
    
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
    
    
    var categories : [Category] {
        var _categories : [Category] = []
        for (key,value) in Resource.sharedInstance().categories {
            if categoryIDs.contains(key) {
                _categories.append(value)
            }
        }
        return _categories
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
    var currency : Currency? {
        return Resource.sharedInstance().currencies[currencyID]
    }
    
    init(id: String, name: String, icon: String, currencyID: String, creatorID: String, balance: Double, totInc: Double, totExp: Double, creationDate: Double, isPersonal: Bool, memberTypes: [String: MemberType], categoryIDs: [String], isOpen: Bool, color : String) {
        self.currencyID = currencyID
        self.balance = balance
        self.totalIncome = totInc
        self.totalExpense = totExp
        self.isPersonal = isPersonal
        self.categoryIDs = categoryIDs
        super.init(id: id, name: name, icon: icon, creatorID: creatorID, creationDate: creationDate, memberTypes: memberTypes, isOpen: isOpen, color: color)
    }
    func addCategory(category: String) {
        if !categoryIDs.contains(category) {
            categoryIDs.append(category)
        }
    }
    func removeCategory(category : String){
        for i in 0..<categoryIDs.count {
            if categoryIDs[i] == category {
                categoryIDs.removeAtIndex(i)
                return
            }
        }
    }
    func getCategoryIDs() -> [String]{
        return categoryIDs
    }
}
extension UIColor{
    var stringRepresentation : String {
        let color = self.CGColor
        
        let numComponents = CGColorGetNumberOfComponents(color);
        
        if numComponents == 4 {
            let components = CGColorGetComponents(color);
            let red = components[0];
            let green = components[1];
            let blue = components[2];
            let alpha = components[3];
            return "\(red):\(green):\(blue):\(alpha)"
        }
        return ""
    }
    convenience init(string : String) {
        let comps = string.componentsSeparatedByString(":")
        if comps.count == 4 {
            self.init(red: CGFloat(Double(comps[0])!), green: CGFloat(Double(comps[1])!), blue: CGFloat(Double(comps[2])!), alpha: CGFloat(Double(comps[3])!))
        }else{
            self.init()
        }
    }
}
protocol WalletDelegate {
    func walletAdded(wallet : UserWallet)
    func walletUpdated(wallet : UserWallet)
    func WalletDeleted(wallet : UserWallet)
}
protocol WalletMemberDelegate {
    func memberAdded(member : User, ofType : MemberType, wallet : Wallet)
    func memberLeft(member : User,ofType : MemberType, wallet : Wallet)
    func memberUpdated(member :  User, ofType : MemberType, wallet : Wallet)
}
protocol WalletCategoryDelegate {
    func categoryAdded(category: Category, wallet : Wallet)
    func categoryUpdated(category: Category, wallet : Wallet)
    func categoryRemoved(category: Category, wallet : Wallet)
}

