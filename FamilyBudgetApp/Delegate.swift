
import Foundation

class Delegate {
    fileprivate static var singleInstance : Delegate?
    class func sharedInstance() -> Delegate {
        guard let instance = singleInstance else {
            singleInstance = Delegate()
            return singleInstance!
        }
        return instance
    }
    fileprivate var userDelegates : [UserDelegate] = []
    fileprivate var walletDelegates : [WalletDelegate] = []
    fileprivate var walletMemberDelegates : [WalletMemberDelegate] = []
    fileprivate var walletCategoryDelegates : [WalletCategoryDelegate] = []
    fileprivate var transactionDelegates : [TransactionDelegate] = []
    fileprivate var transRequestDelegates : [TransactionRequestDelegate] = []
    fileprivate var taskDelegates : [TaskDelegate] = []
    fileprivate var taskMemberDelegates : [TaskMemberDelegate] = []
    fileprivate var budgetDelegates : [BudgetDelegate] = []
    fileprivate var budgetMemberDelegates : [BudgetMemberDelegate] = []
    fileprivate var budgetCategoryDelegates : [BudgetCategoryDelegate] = []
    fileprivate var categoryDelegates : [CategoryDelegate] = []
    fileprivate var currencyDelegates : [CurrencyDelegate] = []
    fileprivate var notificationDelegates : [NotificationDelegate] = []
    
    func addUserDelegate(_ delegate : UserDelegate){
        userDelegates.append(delegate)
    }
    func addWalletDelegate(_ delegate : WalletDelegate){
        walletDelegates.append(delegate)
    }
    func addWalletMemberDelegate(_ delegate : WalletMemberDelegate){
        walletMemberDelegates.append(delegate)
    }
    func addWalletCategoryDelegate(_ delegate : WalletCategoryDelegate){
        walletCategoryDelegates.append(delegate)
    }
    func addTransactionDelegate(_ delegate : TransactionDelegate){
        transactionDelegates.append(delegate)
    }
    func addTransRequestDelegate(_ delegate : TransactionRequestDelegate){
        transRequestDelegates.append(delegate)
    }
    func addTaskDelegate(_ delegate : TaskDelegate){
        taskDelegates.append(delegate)
    }
    func addTaskMemberDelegate(_ delegate : TaskMemberDelegate){
        taskMemberDelegates.append(delegate)
    }
    func addBudgetDelegate(_ delegate : BudgetDelegate){
        budgetDelegates.append(delegate)
    }
    func addBudgetMemberDelegates(_ delegate : BudgetMemberDelegate){
        budgetMemberDelegates.append(delegate)
    }
    func addBudgetCategoryDelegate(_ delegate : BudgetCategoryDelegate){
        budgetCategoryDelegates.append(delegate)
    }
    func addCategoryDelegate(_ delegate : CategoryDelegate){
        categoryDelegates.append(delegate)
    }
    func addCurrencyDelegate(_ delegate  : CurrencyDelegate){
        currencyDelegates.append(delegate)
    }
    func addNotificationDelegate(_ delegate : NotificationDelegate){
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
    func getTransactionRequestDelegates() -> [TransactionRequestDelegate] {
        return transRequestDelegates
    }
    func getTaskDelegates() -> [TaskDelegate]{
        return taskDelegates
    }
    func getTaskMemberDelegates() -> [TaskMemberDelegate]{
        return taskMemberDelegates
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
