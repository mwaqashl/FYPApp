//
//  Resource.swift
//  Penzy
//
//  Created by MacUser on 8/29/16.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation

class Resource {
    private static var singleInstance : Resource = Resource()
    class func sharedInstance() -> Resource {
        return singleInstance
    }
    var users : [String: User] = [:]
    var currentUser : CurrentUser? // computed
    var currentUserId : String?
    var userWallets : [String : UserWallet] = [:]
    var categories : [String : Category] = [:]
    var currencies : [String : Currency] = [:]
    var transactions : [String : Transaction] = [:]
    var recurringTransactions : [String : RecurringTransaction] = [:]
    var transactionRequests : [String : TransactionRequest] = [:]
    var budgets : [String : Budget] = [:]
    var tasks : [String : Task] = [:]
    var recurringTasks : [String : RecurringTask] = [:]
    var notifications : [String : Notification] = [:]
    func reset(){
        Resource.singleInstance = Resource()
    }
    
    
}
func getTaskStatus(rawValue : Int) -> TaskStatus {
    return rawValue == 0 ? TaskStatus.Open : TaskStatus.Completed
}
class helperFunctions {
    class func getSubscriptionType(rawValue : Int) -> SubscriptionType {
        return rawValue == 0 ? SubscriptionType.None : rawValue == 1 ? SubscriptionType.Monthly : SubscriptionType.Yearly
    }
    class func getMemberType(rawValue : Int) -> MemberType {
        return rawValue == 0 ? MemberType.Member : rawValue == 1 ? MemberType.Admin : MemberType.Owner
    }
}