//
//  ChatManager.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 26/05/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import Foundation
import Firebase

class ChatManager {
    
    
    fileprivate var ref = Database.database().reference()
    fileprivate static var singleTonInstance = ChatManager()
    
    static func sharedInstance() -> ChatManager {
        return singleTonInstance
    }
    
    func addNewMessage(msg: Message) {
        
        let msgRef = ref.child("Chat").child(msg.walletID).childByAutoId()
        
        let data : [String:Any] = ["message":msg.message, "sender": msg.sender, "timestamp":msg.timestamp.timeIntervalSince1970]
        
        msgRef.setValue(data)
        
        for member in msg.wallet.members {
            print("Loop")
            if member.getUserID() != Resource.sharedInstance().currentUserId {
                guard let notifUser = Resource.sharedInstance().users[member.getUserID()] as? CurrentUser else {
                    continue
                }
                if let deviceID = notifUser.deviceID {
                    
                    NotificationManager.sharedInstance().sendChatNotification(toDevicewith: deviceID, forGeneric: msg.walletID, withTitle: "Message From \(Resource.sharedInstance().users[msg.sender]!.userName)", forMessage: msg.message, withCallback: { (flag) in
                        print("Notification sent", flag ? "Success" : "Failed")
                        
                    })
                }
            }
        }
        
    }
    
    
}
