//
//  BudgetManager.swift
//  Penzy
//
//  Created by Waqas Hussain on 31/08/2016.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation
import Firebase

class BudgetManager {
    
    private static var singleTonInstance = BudgetManager()
    
    static func sharedInstance() -> BudgetManager {
        return singleTonInstance
    }
    /**
     Add a new budget in Wallet,
     Add members to newly added budget
     Add categories to newly added budget
     
     :param: budget to add
     
     */
    func addNewBudget(budget: Budget) {
        
        let ref = FIRDatabase.database().reference()
        let budRef = ref.child("Budgets").childByAutoId()
        
        let data : NSMutableDictionary = [
            
            "allocAmount": budget.allocAmount,
            "title": budget.title,
            "period": budget.period,
            "lastRenewed": budget.lastRenewed.timeIntervalSince1970*1000,
            "isOpen": budget.isOpen,
            "cyclesRelated": budget.cyclesRelated,
            "walletID": budget.walletID
        ]
        
        if budget.comments != nil {
            data["comments"] = budget.comments
        }
        if budget.extraFunds != nil {
            data["extraFunds"] = budget.extraFunds
        }
        if budget.recurring != nil {
            data["recurring"] = budget.recurring
        }
        
        budRef.setValue(data)
        addMembersToBudget(budRef.key, members: budget.getMemberIDs())
        addCategoriesToBudget(budRef.key, categories: budget.getCategoryIDs())
        
    }
    
    
    /**
     Removes budget from Wallet in Database
     
     :param: Budget to Remove
     
     */
    func removeBudgetFromWallet(budget: Budget) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("Budgets/\(budget.id)").removeValue()
        ref.child("BudgetCategories/\(budget.id)").removeValue()
        ref.child("BudgetMembers/\(budget.id)").removeValue()
        
    }
    
    /**
     Update budget In Wallet to Database
     
     :param: Budget to Update
     
     */
    func updateBudgetInWallet(budget: Budget) {
        
        let ref = FIRDatabase.database().reference()
        let budRef = ref.child("Budgets/\(budget.id)")
        
        let data : NSMutableDictionary = [
            
            "allocAmount": budget.allocAmount,
            "title": budget.title,
            "period": budget.period,
            "lastRenewed": budget.lastRenewed.timeIntervalSince1970*1000,
            "isOpen": budget.isOpen,
            "cyclesRelated": budget.cyclesRelated
        ]
        
        if budget.comments != nil {
            data["comments"] = budget.comments
        }
        if budget.extraFunds != nil {
            data["extraFunds"] = budget.extraFunds
        }
        if budget.recurring != nil {
            data["recurring"] = budget.recurring
        }
        
        budRef.updateChildValues(data as [NSObject : AnyObject])
        
    }
    
    /**
     Update Categories in a budget to Database
     
     :param: BudgetID For reference and categoryIDs for updation
     
     */
    func addCategoriesToBudget(budgetID: String, categories: [String]) {
        
        let ref = FIRDatabase.database().reference()
        let catRef = ref.child("BudgetCategories/\(budgetID)")
        
        var data = [String:Bool]()
        
        for category in categories {
            data[category] = true
        }
        
        catRef.setValue(data)
    }
    
    /**
     Update Members in a budget to Database
     
     :param: BudgetID For reference and memberIDs for updation
     
     */
    func addMembersToBudget(budgetID: String, members: [String]) {
        
        let ref = FIRDatabase.database().reference()
        let memRef = ref.child("BudgetMembers/\(budgetID)")
        
        var data = [String:Bool]()
        
        for member in members {
            data[member] = true
        }
        
        memRef.setValue(data)
        
    }
    
}