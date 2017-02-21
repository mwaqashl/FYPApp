import Foundation
import Firebase

class NotificationObserver {
    fileprivate let FIRKeys = ["Notifications", //0
        "module", //1
        "type", //2
        "message", //3
        "isPush", //4
        "details", //5
        "isSent", //6
        "users"] //7
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate static var singleInstance : NotificationObserver?
    class func sharedInstance() -> NotificationObserver {
        guard let instance = NotificationObserver.singleInstance else {
            NotificationObserver.singleInstance = NotificationObserver()
            return singleInstance!
        }
        return instance
    }
    func startObserving() {
        observeNotificationAdded()
        observeNotificationUpdated()
    }
    func stopObserving(){
        ref.child(FIRKeys[0]).removeAllObservers()
    }
    fileprivate func observeNotificationAdded(){
        let notificationRef = ref.child(FIRKeys[0])
        notificationRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let notification = Notification(id: snapshot.key, module: dict[self.FIRKeys[1]] as! String, type: dict[self.FIRKeys[2]] as! String, details: dict[self.FIRKeys[5]] as! [String: AnyObject], isPush: dict[self.FIRKeys[4]] as! Bool, users: dict[self.FIRKeys[7]] as! [String], message: dict[self.FIRKeys[3]] as! String)
            Resource.sharedInstance().notifications[snapshot.key] = notification
            Delegate.sharedInstance().getNotificationDelegates().forEach({ (notifDel) in
                notifDel.notificationAdded(notification)
            })
        })
    }
    fileprivate func observeNotificationUpdated(){
        let notificationRef = ref.child(FIRKeys[0])
        notificationRef.observe(FIRDataEventType.childChanged, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let notification = Notification(id: snapshot.key, module: dict[self.FIRKeys[1]] as! String, type: dict[self.FIRKeys[2]] as! String, details: dict[self.FIRKeys[5]] as! [String: AnyObject], isPush: dict[self.FIRKeys[4]] as! Bool, users: dict[self.FIRKeys[7]] as! [String], message: dict[self.FIRKeys[3]] as! String)
            Resource.sharedInstance().notifications[snapshot.key] = notification
        })
    }
    fileprivate func observeNotificationDeleted(){
        let notificationRef = ref.child(FIRKeys[0])
        notificationRef.observe(FIRDataEventType.childRemoved, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let notification = Notification(id: snapshot.key, module: dict[self.FIRKeys[1]] as! String, type: dict[self.FIRKeys[2]] as! String, details: dict[self.FIRKeys[5]] as! [String: AnyObject], isPush: dict[self.FIRKeys[4]] as! Bool, users: dict[self.FIRKeys[7]] as! [String], message: dict[self.FIRKeys[3]] as! String)
            Resource.sharedInstance().notifications[snapshot.key] = nil
            Delegate.sharedInstance().getNotificationDelegates().forEach({ (notifDel) in
                notifDel.notificationDeleted(notification)
            })
        })
    }
}
