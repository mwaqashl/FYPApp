//
//  Budget.swift
//  AccBook
//
//  Created by MacUser on 8/17/16.
//  Copyright © 2016 Collage. All rights reserved.
//

import Foundation

class Budget {
    
    var id : String
    var allocAmount : Double
    var title : String
    var period : Int
    var lastRenewed : NSDate
    var comments : String?
    var recurring : Int?
    var cyclesRelated: Bool
    var extraFunds: Double?
    var isOpen : Bool
    var categories : [Category] {
        var _categories : [Category] = []
        Resource.sharedInstance().categories.forEach { (key,value) in
            if categoryIDs.contains(key) {
                _categories.append(value)
            }
        }
        return _categories
    }
    private var categoryIDs: [String]
    var members : [User] {
        var _members : [User] = []
        Resource.sharedInstance().users.forEach { (key,value) in
            if memberIDs.contains(key) {
                _members.append(value)
            }
        }
        return _members
    }
    private var memberIDs: [String]
    var walletID: String
    var wallet : UserWallet? {
        return Resource.sharedInstance().userWallets[walletID]
    }
    
    
    init(budgetId : String, allocAmount : Double, title : String, period : Int, lastRenewed : Double, comments : String?, recurring : Int?, cyclesRelated: Bool, extraFunds: Double?, isOpen : Bool, categoryIDs: [String], memberIDs: [String], walletID: String) {
        
        self.id = budgetId
        self.allocAmount = allocAmount
        self.title = title
        self.period = period
        self.lastRenewed = NSDate(timeIntervalSince1970: lastRenewed/1000)
        self.comments = comments
        self.recurring = recurring
        self.cyclesRelated = cyclesRelated
        self.extraFunds = extraFunds
        self.isOpen = isOpen
        self.categoryIDs = categoryIDs
        self.memberIDs = memberIDs
        self.walletID = walletID
    }
    func addMember(memberId : String){
        if !memberIDs.contains(memberId) {
            memberIDs.append(memberId)
        }
    }
    func removeMember(memberId : String){
        for i in 0..<memberIDs.count {
            if memberIDs[i] == memberId {
                memberIDs.removeAtIndex(i)
                return
            }
        }
    }
    func getMemberIDs() -> [String] {
        return memberIDs
    }
    func addCategory(categoryId : String){
        if !categoryIDs.contains(categoryId) {
            categoryIDs.append(categoryId)
        }
    }
    func getCategoryIDs() -> [String] {
        return categoryIDs
    }
    func removeCategory(categoryId : String){
        for i in 0..<categoryIDs.count {
            if categoryIDs[i] == categoryId {
                categoryIDs.removeAtIndex(i)
                return
            }
        }
    }
}

protocol BudgetDelegate {
    func budgetAdded(budget : Budget)
    func budgetUpdated(budget : Budget)
    func budgetDeleted(budget: Budget)
}
protocol BudgetCategoryDelegate {
    func categoryAdded(category: Category, budget : Budget)
    func categoryRemoved(category: Category, budget : Budget)
}
protocol BudgetMemberDelegate {
    func memberAdded(member : User, budget : Budget)
    func memberLeft(member : User, budget : Budget)
}