
import Foundation


class Notification {
    
    var notifID: String
    var module: String
    var type: String
    var details: [String: AnyObject]
    var isPush : Bool
    var users : [String]
    var message : String
    
    init(id: String, module: String, type: String, details: [String:AnyObject], isPush: Bool, users: [String], message: String) {
        
        self.notifID = id
        self.details = details
        self.users = users
        self.message = message
        self.isPush = isPush
        self.module = module
        self.type = type
    }

    
    
}
protocol NotificationDelegate {
    func notificationAdded(_ notif : Notification)
    func notificationDeleted(_ notif: Notification)
}
