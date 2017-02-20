//
//  WalletManager.swift
//  Penzy
//
//  Created by Waqas Hussain on 30/08/2016.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation
import Firebase

class WalletManager {
    
    private static var singleTonInstance = WalletManager()
    
    static func sharedInstance() -> WalletManager {
        return singleTonInstance
    }
    
    /**
     Creates a new wallet
     Call this method when a new Wallet is created by User
     
     
     :param: Newly made Wallet object
     
     */
    func addWallet(wallet: UserWallet) {
        let ref = FIRDatabase.database().reference()
        
        let walletRef = ref.child("WalletInfo").childByAutoId()
        let walletDet = ref.child("Wallets").child(walletRef.key)
        wallet.id = walletRef.key
        var data : NSMutableDictionary = [
            "name" : wallet.name,
            "icon" : wallet.icon
        ]
        
        walletRef.setValue(data)
        
        data = [
            "name" : wallet.name,
            "icon" : wallet.icon,
            "color": wallet.color.stringRepresentation,
            "isOpen" : wallet.isOpen,
            "isTravel" : wallet.isTravel,
            "currency" : wallet.currencyID,
            "creator" : wallet.creatorID,
            "balance" : wallet.balance,
            "totExpense" : wallet.totalExpense,
            "totIncome" : wallet.totalIncome,
            "creationDate" : FIRServerValue.timestamp(),
            "isPersonal" : wallet.isPersonal
        ]
        
        walletDet.setValue(data)
        UserManager.sharedInstance().addUserFriends(wallet.creatorID, friends: wallet.memberTypes.keys.sort())
        for (member,type) in wallet.memberTypes {
            
            addMemberToWallet(wallet, member: member,type: type)
            
        }
//        for category in wallet.categories! {
//            
//            addCategoryToWallet(category!, walletID: walletRef.key)
//            
//        }
    }
    
    /**
     Delete a Wallet
     Call this method when a user Deletes a wallet and wants to delete data from database.
     
     
     :param: wallet to be deleted!
     
     */
    func removeWallet(wallet: UserWallet) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("Wallets/\(wallet.id)").removeValue()
        ref.child("WalletCategories/\(wallet.id)").removeValue()
        ref.child("WalletMembers/\(wallet.id)").removeValue()
        
    }
    
    /**
     Update wallets data
     Call this method when a wallet data is edited by user
     
     
     :param: updated wallet
     
     */
    func updateWallet(wallet: UserWallet) {
        
        let ref = FIRDatabase.database().reference()
        let walletRef = ref.child("Wallets/\(wallet.id)")
        
        let data : NSMutableDictionary = [
            "name" : wallet.name,
            "icon" : wallet.icon,
            "color": wallet.color.stringRepresentation,
            "status" : wallet.isOpen,
            "isTravel" : wallet.isTravel,
            "currency" : wallet.currencyID,
            "creator" : wallet.creatorID,
            "creationDate" : wallet.creationDate,
            "isPersonal" : wallet.isPersonal
        ]
        
        walletRef.updateChildValues(data as [NSObject : AnyObject])
        
        for (member,type) in wallet.memberTypes {
            addMemberToWallet(wallet, member: member, type: type)
        }
        for category in wallet.categories {
            addCategoryToWallet(category, walletID: walletRef.key)
        }

    }
    
    /**
     Add a member to wallet
     Call this method when a new member is added in wallet. this method ask user to add this wallet at his side
     
     
     :param: wallet object, userId of member and membership type of user
     
     */
    func addMemberToWallet(wallet: UserWallet, member: String, type: MemberType) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("WalletMembers/\(wallet.id)/\(member)").setValue(type.hashValue)
        UserManager.sharedInstance().addWalletInUser(member, walletID: wallet.id, isPersonal: wallet.isPersonal)
    }
    
    /**
     remove member from wallet
     Call this method when a member is removed from wallet
     
     :param: walletID for reference and memberID
     
     */
    func removeMemberFromWallet(walletID: String, memberID: String) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("WalletMembers/\(walletID)/\(memberID)").removeValue()
        ref.child("WalletCategories/\(walletID)").removeValue()
        
        UserManager.sharedInstance().removeWalletFromUser(memberID, walletID: walletID)
        
    }
    
    /**
     Add category.
     Call this method when a new category is added to wallet
     
     
     :param: walletID and Cateogory
     
     */
    func addCategoryToWallet(category: Category, walletID: String) {
        
        let ref = FIRDatabase.database().reference()
        let catRef = ref.child("WalletCategories/\(walletID)")
        
        if category.isDefault {
            catRef.child(category.id).setValue(true)
        }
        else {
            catRef.childByAutoId().setValue([
                
                "name":category.name,
                "icon":category.icon,
                "color": category.color.stringRepresentation,
                "isExpense":category.isExpense
            ])
        }
    }
    
    /**
     Delete Category.
     Call this method when a category is removed from wallet
     
     
     :param: Newly made Transaction
     
     */
    func removeCategoryFromWallet(walletID: String, categoryID: String) {
        let ref = FIRDatabase.database().reference()
        ref.child("WalletCategories/\(walletID)/\(categoryID)").removeValue()
    }
    
    // Share Wallet Remaining.
    
    
    
}


class CurrencyManager {
    
    
    private static var singleTonInstance = CurrencyManager()
    
    static func sharedInstance() -> CurrencyManager {
        return singleTonInstance
    }
    
    func addCurrency(currency: Currency) {
        
        let ref = FIRDatabase.database().reference().child("Currency").childByAutoId()
        
        let data = ["name": currency.name,
            "icon": currency.icon,
            "code": currency.code
        ]
        ref.setValue(data)
    }
    
}


class CategoryManager {
    
    
    private static var singleTonInstance = CategoryManager()
    
    static func sharedInstance() -> CategoryManager {
        return singleTonInstance
    }
    
    func addCurrency(category: Category) {
        
        let ref = FIRDatabase.database().reference().child("DefaultCategories").childByAutoId()
        
        let data = ["name": category.name,
                    "icon": category.icon,
                    "color": category.color.stringRepresentation
        ]
        ref.setValue(data)
    }
    
}
