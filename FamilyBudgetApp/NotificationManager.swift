
import Foundation
import Firebase

/*
 
 Notification Comments:
 
 Modules 
 
 - "Wallet"
        Types:
            - StatusChanged
            - OwnerChanged
 
 - "Budget"
        Types:
            - StatusChanged
            - OwnerChanged
 
 - "Task"
        Types:
            - AddTask
            - StatusChanged
 
 - "Transaction"
 - "User"
 

 */

class NotificationManager {
    
    fileprivate static var singleTonInstance = NotificationManager()
    fileprivate let ref = FIRDatabase.database().reference()
    
    static func sharedInstance() -> NotificationManager {
        return singleTonInstance
    }
    
    
    func addNewNotification(_ notification: Notification) {
        
        let notRef = ref.child("Notifications").childByAutoId()
        
        let data : NSMutableDictionary = [
            
            "module" : notification.module,
            "type" : notification.type,
            "isPush" : notification.isPush,
            "users" : notification.users,
            "message" : notification.message,
            "details" : notification.details
            
        ]
        
        notRef.setValue(data)
        
    }
    
}
