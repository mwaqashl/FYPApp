//
//  ChatMessage.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 26/05/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import Foundation
import UIKit

class Message {
    
    var id: String
    var message: String
    var sender: String
    var timestamp: Date
    var walletID: String
    var wallet: Wallet {
        
        guard let wallet = Resource.sharedInstance().userWallets[walletID] else {
            
            return Wallet(id: walletID, name: "Loading", icon: "", creatorID: "Loading", creationDate: 0, memberTypes: [:], isOpen: true, color: UIColor.black.stringRepresentation)
            
        }
        return wallet
        
    }
    
    
    init(id: String, message: String, date: Double, senderID: String, walletID: String) {
        self.id = id
        self.message = message
        self.sender = senderID
        self.timestamp = Date(timeIntervalSince1970: date)
        self.walletID = walletID
    }
    
}
