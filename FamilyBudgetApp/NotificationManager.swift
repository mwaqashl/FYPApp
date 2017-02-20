//
//  NotificationManager.swift
//  Penzy
//
//  Created by Waqas Hussain on 09/09/2016.
//  Copyright © 2016 TechCollage. All rights reserved.
//

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
    
    private static var singleTonInstance = NotificationManager()
    private let ref = FIRDatabase.database().reference()
    
    static func sharedInstance() -> NotificationManager {
        return singleTonInstance
    }
    
    
    func addNewNotification(notification: Notification) {
        
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