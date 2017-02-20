//
//  Delegate.swift
//  Penzy
//
//  Created by MacUser on 9/3/16.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation

class Delegate {
    private static var singleInstance : Delegate?
    class func sharedInstance() -> Delegate {
        guard let instance = singleInstance else {
            singleInstance = Delegate()
            return singleInstance!
        }
        return instance
    }
    private var userDelegates : [UserDelegate] = []
    private var walletDelegates : [WalletDelegate] = []
    private var walletMemberDelegates : [WalletMemberDelegate] = []
    private var walletCategoryDelegates : [WalletCategoryDelegate] = []
    private var transactionDelegates : [TransactionDelegate] = []
    private var recurTransDelegates : [ScheduledTransactionDelegate] = []
    private var transRequestDelegates : [TransactionRequestDelegate] = []
    private var taskDelegates : [TaskDelegate] = []
    private var recurringTaskDelegates : [ScheduledTaskDelegate] = []
    private var taskMemberDelegates : [TaskMemberDelegate] = []
    private var recurringTaskMemberDelegates : [ScheduledTaskMemberDelegate] = []
    private var budgetDelegates : [BudgetDelegate] = []
    private var budgetMemberDelegates : [BudgetMemberDelegate] = []
    private var budgetCategoryDelegates : [BudgetCategoryDelegate] = []
    private var categoryDelegates : [CategoryDelegate] = []
    private var currencyDelegates : [CurrencyDelegate] = []
    private var notificationDelegates : [NotificationDelegate] = []
    
    func addUserDelegate(delegate : UserDelegate){
        userDelegates.append(delegate)
    }
    func addWalletDelegate(delegate : WalletDelegate){
        walletDelegates.append(delegate)
    }
    func addWalletMemberDelegate(delegate : WalletMemberDelegate){
        walletMemberDelegates.append(delegate)
    }
    func addWalletCategoryDelegate(delegate : WalletCategoryDelegate){
        walletCategoryDelegates.append(delegate)
    }
    func addTransactionDelegate(delegate : TransactionDelegate){
        transactionDelegates.append(delegate)
    }
    func addRecurTransDelegate(delegate : ScheduledTransactionDelegate){
        recurTransDelegates.append(delegate)
    }
    func addTransRequestDelegate(delegate : TransactionRequestDelegate){
        transRequestDelegates.append(delegate)
    }
    func addTaskDelegate(delegate : TaskDelegate){
        taskDelegates.append(delegate)
    }
    func addRecurringTaskDelegate(delegate : ScheduledTaskDelegate){
        recurringTaskDelegates.append(delegate)
    }
    func addTaskMemberDelegate(delegate : TaskMemberDelegate){
        taskMemberDelegates.append(delegate)
    }
    func addRecurringTaskMemberDelegate(delegate : ScheduledTaskMemberDelegate){
        recurringTaskMemberDelegates.append(delegate)
    }
    func addBudgetDelegate(delegate : BudgetDelegate){
        budgetDelegates.append(delegate)
    }
    func addBudgetMemberDelegates(delegate : BudgetMemberDelegate){
        budgetMemberDelegates.append(delegate)
    }
    func addBudgetCategoryDelegate(delegate : BudgetCategoryDelegate){
        budgetCategoryDelegates.append(delegate)
    }
    func addCategoryDelegate(delegate : CategoryDelegate){
        categoryDelegates.append(delegate)
    }
    func addCurrencyDelegate(delegate  : CurrencyDelegate){
        currencyDelegates.append(delegate)
    }
    func addNotificationDelegate(delegate : NotificationDelegate){
        notificationDelegates.append(delegate)
    }
    
    func getUserDelegates() -> [UserDelegate]{
        return userDelegates
    }
    func getWalletDelegates() -> [WalletDelegate]{
        return walletDelegates
    }
    func getWalletMemberDelegates() -> [WalletMemberDelegate]{
        return walletMemberDelegates
    }
    func getWalletCategoryDelegates() -> [WalletCategoryDelegate]{
        return walletCategoryDelegates
    }
    func getTransactionDelegates() -> [TransactionDelegate]{
        return transactionDelegates
    }
    func getRecurTransactionDelegates() -> [ScheduledTransactionDelegate]{
        return recurTransDelegates
    }
    func getTransactionRequestDelegates() -> [TransactionRequestDelegate] {
        return transRequestDelegates
    }
    func getTaskDelegates() -> [TaskDelegate]{
        return taskDelegates
    }
    func getRucurringTaskDelegates() -> [ScheduledTaskDelegate]{
        return recurringTaskDelegates
    }
    func getTaskMemberDelegates() -> [TaskMemberDelegate]{
        return taskMemberDelegates
    }
    func getRecurringTaskMemberDelegates() -> [ScheduledTaskMemberDelegate]{
        return recurringTaskMemberDelegates
    }
    func getBudgetDelegates() -> [BudgetDelegate]{
        return budgetDelegates
    }
    func getBudgetMemberDelegates() -> [BudgetMemberDelegate]{
        return budgetMemberDelegates
    }
    func getBudgetCategoryDelegates() -> [BudgetCategoryDelegate]{
        return budgetCategoryDelegates
    }
    func getCategoryDelegates() -> [CategoryDelegate] {
        return categoryDelegates
    }
    func getCurrencyDelegates() -> [CurrencyDelegate]{
        return currencyDelegates
    }
    func getNotificationDelegates() -> [NotificationDelegate]{
        return notificationDelegates
    }
}