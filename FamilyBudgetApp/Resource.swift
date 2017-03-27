
import Foundation

class Resource {
    fileprivate static var singleInstance : Resource = Resource()
    class func sharedInstance() -> Resource {
        return singleInstance
    }
    var users : [String: User] = [:]
    var currentUser : CurrentUser? {
        return self.users[currentUserId!] as? CurrentUser
    }
    var currentUserId : String?
    var userWallets : [String : UserWallet] = [:]
    var categories : [String : Category] = [:]
    var currencies : [String : Currency] = [:]
    var transactions : [String : Transaction] = [:]
    var transactionRequests : [String : TransactionRequest] = [:]
    var budgets : [String : Budget] = [:]
    var tasks : [String : Task] = [:]
    var notifications : [String : Notification] = [:]
    var currentWalletID : String?
    var currentWallet : UserWallet? {
        return self.userWallets[currentWalletID!]
    }
    func reset(){
        let old = Resource.singleInstance
        Resource.singleInstance = Resource()
        Resource.singleInstance.categories = old.categories
        Resource.singleInstance.currencies = old.currencies
    }
    
    
}
func getTaskStatus(_ rawValue : Int) -> TaskStatus {
    return rawValue == 0 ? TaskStatus.open : TaskStatus.completed
}
class helperFunctions {
    class func getSubscriptionType(_ rawValue : Int) -> SubscriptionType {
        return rawValue == 0 ? SubscriptionType.none : rawValue == 1 ? SubscriptionType.monthly : SubscriptionType.yearly
    }
    class func getMemberType(_ rawValue : Int) -> MemberType {
        return rawValue == 0 ? MemberType.member : rawValue == 1 ? MemberType.admin : MemberType.owner
    }
}
