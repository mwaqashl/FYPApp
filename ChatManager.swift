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
        
    }
    
    
}
