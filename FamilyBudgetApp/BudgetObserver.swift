//
//  BudgetObserver.swift
//  Penzy
//
//  Created by MacUser on 9/6/16.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation
import Firebase

class BudgetObserver {
    private let FIRKeys = ["Budgets", //0
                           "BudgetMembers", //1
                           "BudgetCategories", //2
                           "allocAmount", //3
                           "title", //4
                           "period", //5
                           "lastRenewed", //6
                           "comments", //7
                           "cyclesRelated", //8
                           "recurring", //9
                           "extraFunds", //10
                           "isOpen", //11
                           "walletID" ] //12
    private var ref = FIRDatabase.database().reference()
    private static var singleInstance : BudgetObserver?
    class func sharedInstance() -> BudgetObserver {
        guard let instance = BudgetObserver.singleInstance else {
            BudgetObserver.singleInstance = BudgetObserver()
            return singleInstance!
        }
        return instance
    }
    private var _autoObserve : Bool = true
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
    func startObserving(){
        observeBudgetAdded()
        observeBudgetDeleted()
        observeBudgetUpdated()
    }
    func startObservingBudget(budget : Budget){
        stopObservingBudget(budget)
        observeBudgetMemberAdded(budget);
        observeBudgetMemberUpdated(budget);
        observeBudgetMemberRemoved(budget);
        observeBudgetCategoryAdded(budget);
        observeBudgetCategoryUpdated(budget);
        observeBudgetCategoryRemoved(budget);
    }
    func stopObservingBudget(budget :  Budget){
        FIRDatabase.database().reference().child(FIRKeys[1]).child(budget.id).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[2]).child(budget.id).removeAllObservers()
    }
    func stopObserving(){
        FIRDatabase.database().reference().child(FIRKeys[0]).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[1]).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[2]).removeAllObservers()
    }
    private func observeBudgetAdded(){
        let budgetRef = ref.child(FIRKeys[0])
        budgetRef.observeEventType(FIRDataEventType.ChildAdded, withBlock:  { (snapshot) in
            guard let dict = snapshot.value else {
                return
            }
            let budget = Budget(budgetId: snapshot.key, allocAmount: dict[self.FIRKeys[3]] as! Double,  title: dict[self.FIRKeys[4]] as! String, period: dict[self.FIRKeys[5]] as! Int, lastRenewed: (dict[self.FIRKeys[6]] as! Double), comments: dict[self.FIRKeys[7]] as? String, recurring: dict[self.FIRKeys[9]] as? Int, cyclesRelated: dict[self.FIRKeys[8]] as! Bool, extraFunds: dict[self.FIRKeys[10]] as? Double, isOpen: dict[self.FIRKeys[11]] as! Bool, categoryIDs: [], memberIDs: [], walletID: dict[self.FIRKeys[12]] as! String)
            Resource.sharedInstance().budgets[snapshot.key] = budget
            if self.autoObserve { self.observeBudgetMemberAdded(budget); self.observeBudgetMemberUpdated(budget); self.observeBudgetMemberRemoved(budget);
                self.observeBudgetCategoryAdded(budget); self.observeBudgetCategoryUpdated(budget); self.observeBudgetCategoryRemoved(budget); }
            Delegate.sharedInstance().getBudgetDelegates().forEach({ (budgetDel) in
                budgetDel.budgetAdded(budget)
            })
        })
    }
    private func observeBudgetUpdated(){
        let budgetRef = ref.child(FIRKeys[0])
        budgetRef.observeEventType(FIRDataEventType.ChildChanged, withBlock:  { (snapshot) in
            guard let dict = snapshot.value else {
                return
            }
            let budget = Resource.sharedInstance().budgets[snapshot.key]!
            budget.title = dict[self.FIRKeys[4]] as! String
            budget.allocAmount = dict[self.FIRKeys[3]] as! Double
            budget.period = dict[self.FIRKeys[5]] as! Int
            budget.lastRenewed = NSDate(timeIntervalSince1970 : (dict[self.FIRKeys[6]] as! Double)/1000)
            budget.comments = dict[self.FIRKeys[7]] as? String
            budget.recurring = dict[self.FIRKeys[9]] as? Int
            budget.cyclesRelated = dict[self.FIRKeys[8]] as! Bool
            budget.extraFunds = dict[self.FIRKeys[10]] as? Double
            budget.isOpen = dict[self.FIRKeys[11]] as! Bool
            Resource.sharedInstance().budgets[snapshot.key] = budget
            Delegate.sharedInstance().getBudgetDelegates().forEach({ (budgetDel) in
                budgetDel.budgetUpdated(budget)
            })
        })
    }
    private func observeBudgetDeleted(){
        let budgetRef = ref.child(FIRKeys[0])
        budgetRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock:  { (snapshot) in
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
    private func observeBudgetMemberAdded(budget: Budget){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let budgetRef = ref.child(FIRKeys[1]).child(budget.id)
        budgetRef.observeEventType(FIRDataEventType.ChildAdded, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if snapshot.value as! Bool { Resource.sharedInstance().budgets[budget.id]?.addMember(snapshot.key) }
            Delegate.sharedInstance().getBudgetMemberDelegates().forEach({ (budgetMemDel) in
                if let user = Resource.sharedInstance().users[snapshot.key] {
                    budgetMemDel.memberAdded(user, budget: budget)
                }
            })
        })
    }
    private func observeBudgetMemberUpdated(budget: Budget){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let budgetRef = ref.child(FIRKeys[1]).child(budget.id)
        budgetRef.observeEventType(FIRDataEventType.ChildChanged, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if snapshot.value as! Bool {
                Resource.sharedInstance().budgets[budget.id]?.addMember(snapshot.key)
                Delegate.sharedInstance().getBudgetMemberDelegates().forEach({ (budgetMemDel) in
                    if let user = Resource.sharedInstance().users[snapshot.key] {
                        budgetMemDel.memberAdded(user, budget: budget)
                    }
                })
            }else{
                Resource.sharedInstance().budgets[budget.id]?.removeMember(snapshot.key)
                Delegate.sharedInstance().getBudgetMemberDelegates().forEach({ (budgetMemDel) in
                    if let user = Resource.sharedInstance().users[snapshot.key] {
                        budgetMemDel.memberLeft(user, budget: budget)
                    }
                })
            }
            
        })
    }
    private func observeBudgetMemberRemoved(budget: Budget){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let budgetRef = ref.child(FIRKeys[1]).child(budget.id)
        budgetRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().budgets[budget.id]?.removeMember(snapshot.key)
            Delegate.sharedInstance().getBudgetMemberDelegates().forEach({ (walletMemDel) in
                if let user = Resource.sharedInstance().users[snapshot.key] {
                    walletMemDel.memberLeft(user, budget: budget)
                }
            })
        })
    }
    private func observeBudgetCategoryAdded(budget : Budget){
        let budgetRef = ref.child(FIRKeys[2]).child(budget.id)
        budgetRef.observeEventType(FIRDataEventType.ChildAdded, withBlock:  { (snapshot) in
            guard (snapshot.value) != nil else {
                return
            }
            if !(snapshot.value as! Bool) {return}
            Resource.sharedInstance().budgets[budget.id]?.addCategory(snapshot.key)
            guard let category = Resource.sharedInstance().categories[snapshot.key] else {
                return
            }
            Delegate.sharedInstance().getBudgetCategoryDelegates().forEach({ (walletCatDel) in
                walletCatDel.categoryAdded(category, budget: budget)
            })
        })
    }
    private func observeBudgetCategoryUpdated(budget : Budget){
        let budgetRef = ref.child(FIRKeys[2]).child(budget.id)
        budgetRef.observeEventType(FIRDataEventType.ChildChanged, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if snapshot.value as! Bool {
                Resource.sharedInstance().budgets[budget.id]?.addCategory(snapshot.key)
                guard let category = Resource.sharedInstance().categories[snapshot.key] else {
                    return
                }
                Delegate.sharedInstance().getBudgetCategoryDelegates().forEach({ (walletCatDel) in
                    walletCatDel.categoryAdded(category, budget: budget)
                })
            }else{
                Resource.sharedInstance().budgets[budget.id]?.removeCategory(snapshot.key)
                guard let category = Resource.sharedInstance().categories[snapshot.key] else {
                    return
                }
                Delegate.sharedInstance().getBudgetCategoryDelegates().forEach({ (walletCatDel) in
                    walletCatDel.categoryRemoved(category, budget: budget)
                })
            }
        })
    }
    private func observeBudgetCategoryRemoved(budget : Budget){
        let budgetRef = ref.child(FIRKeys[2]).child(budget.id)
        budgetRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock:  { (snapshot) in
            guard (snapshot.value) != nil else {
                return
            }
            Resource.sharedInstance().budgets[budget.id]?.removeCategory(snapshot.key)
            guard let category = Resource.sharedInstance().categories[snapshot.key] else {
                return
            }
            Delegate.sharedInstance().getBudgetCategoryDelegates().forEach({ (walletCatDel) in
                walletCatDel.categoryRemoved(category, budget: budget)
            })
        })
    }
}