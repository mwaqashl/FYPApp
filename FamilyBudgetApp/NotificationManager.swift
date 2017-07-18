
import Foundation
import Firebase
import Alamofire

enum NotificationType {
    case walletClosed
    case walletOpen
    case addedToWallet
    case removeFromWallet
    case transactionAdded
    case messageRecieved
    case budgetAdded
    case budgetOverflow
    case budgetClosed
    case taskAssigned
    case taskCompleted
}

class NotificationManager {
    
    fileprivate static var singleTonInstance = NotificationManager()
    fileprivate let ref = Database.database().reference()
    
    static func sharedInstance() -> NotificationManager {
        return singleTonInstance
    }
    
    
//    func addNewNotification(_ notification: Notification) {
//        
//        let notRef = ref.child("Notifications").childByAutoId()
//        
//        let data : NSMutableDictionary = [
//            
//            "module" : notification.module,
//            "type" : notification.type,
//            "isPush" : notification.isPush,
//            "users" : notification.users,
//            "message" : notification.message,
//            "details" : notification.details
//        ]
//        
//        notRef.setValue(data)
//        
//    }
    
    func sendNotification(toDevicewith deviceID:String, of type: NotificationType, for genericID:String, withCallback callback: @escaping (Bool)->Void) {
        var title = ""
        var body = ""
        
        
        switch type {
        case .addedToWallet:
            title = "Wallet Update"
            body = "You have been added to a wallet."
            
        case .budgetAdded:
            title = "Budget Update"
            body = "A new budget has been added to a wallet."
            
        case .budgetClosed:
            title = "Budget Closed"
            body = "A budget you are added in has been updated."
            
        case .budgetOverflow:
            title = "Budget Overflowed"
            body = "A budget you are added in is overflowed."
            
        case .messageRecieved:
            title = "New Message Recieved"
            body = "Your Wallet just recieved a new message."
            
        case .removeFromWallet:
            title = "Wallet Update"
            body = "You have been removed from a wallet."
            
        case .taskAssigned:
            title = "Task Assigned"
            body = "A task has been assigned to you in your wallet."
            
        case .taskCompleted:
            title = "Task Completed"
            body = "A task you have been assigned is now completed."
            
        case .transactionAdded:
            title = "Transaction Added"
            body = "A new transaction has been added to your wallet."
            
        case .walletClosed:
            title = "Wallet Update"
            body = "One of your wallet is now closed."
            
        case .walletOpen:
            title = "Wallet Update"
            body = "One of your wallet is now Open."
            
        }
        
        let params : Parameters = ["APIKey":apiKey,"title":title,"body":body,"genericId":genericID,"bundleId":bundleID,"deviceId":deviceID]
        
        Alamofire.request(notificationRequestURL, method: .post, parameters: params).responseJSON { (res) in
            
            if res.error != nil {
                print("Network Error")
                callback(false)
                return
            }
            
            guard let data = res.result.value as? Dictionary<String,Any> else {
                print("Data is not dictionary")
                callback(false)
                return
            }
            
            if data["status"] as! String == "Success" {
                callback(true)
                return
            }
            callback(false)
            print(data["message"])
            
        }
        
    }
    
}
