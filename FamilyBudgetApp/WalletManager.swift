

import Foundation
import Firebase

class WalletManager {
    
    fileprivate static var singleTonInstance = WalletManager()
    
    static func sharedInstance() -> WalletManager {
        return singleTonInstance
    }
    
    /**
     Creates a new wallet
     Call this method when a new Wallet is created by User
     
     
     :param: Newly made Wallet object
     
     */
    func addWallet(_ wallet: UserWallet) -> String {
        let ref = FIRDatabase.database().reference()
        
        
        var walletRef = ref.child("Wallets")
        
        if wallet.isPersonal == true {
            walletRef = walletRef.child(wallet.creatorID)
        }
        else {
            walletRef = walletRef.childByAutoId()
        }
        
        wallet.id = walletRef.key
        let data : NSMutableDictionary = [
            "name" : wallet.name,
            "icon" : wallet.icon,
            "color": wallet.color.stringRepresentation,
            "isOpen" : wallet.isOpen,
            "currency" : wallet.currencyID,
            "creator" : wallet.creatorID,
            "balance" : wallet.balance,
            "totExpense" : wallet.totalExpense,
            "totIncome" : wallet.totalIncome,
            "creationDate" : FIRServerValue.timestamp(),
            "isPersonal" : wallet.isPersonal
        ]
        
        walletRef.setValue(data)
        UserManager.sharedInstance().addUserFriends(wallet.creatorID, friends: wallet.memberTypes.keys.sorted())
        UserManager.sharedInstance().addWalletInUser(wallet.creatorID, walletID: wallet.id, isPersonal: wallet.isPersonal)
        
        for (member,type) in wallet.memberTypes {
            addMemberToWallet(wallet, member: member,type: type)
        }
        return walletRef.key
    }
    
    /**
     Delete a Wallet
     Call this method when a user Deletes a wallet and wants to delete data from database.
     
     :param: wallet to be deleted!
     
     */
    
    func removeWallet(_ wallet: UserWallet) {
        
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
    func updateWallet(_ wallet: UserWallet) {
        
        let ref = FIRDatabase.database().reference()
        let walletRef = ref.child("Wallets/\(wallet.id)")
        
        let data = [
            "name" : wallet.name,
            "icon" : wallet.icon,
            "color": wallet.color.stringRepresentation,
            "status" : wallet.isOpen,
            "currency" : wallet.currencyID,
            "creator" : wallet.creatorID,
            "creationDate" : wallet.creationDate,
            "isPersonal" : wallet.isPersonal
        ] as [String : Any]
        
        walletRef.updateChildValues(data)
        
        for (member,type) in wallet.memberTypes {
            addMemberToWallet(wallet, member: member, type: type)
        }

    }
    
    /**
     Add a member to wallet
     Call this method when a new member is added in wallet. this method ask user to add this wallet at his side
     
     
     :param: wallet object, userId of member and membership type of user
     
     */
    func addMemberToWallet(_ wallet: UserWallet, member: String, type: MemberType) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("WalletMembers/\(wallet.id)/\(member)").setValue(type.hashValue)
        UserManager.sharedInstance().addWalletInUser(member, walletID: wallet.id, isPersonal: wallet.isPersonal)
    }
    
    /**
     remove member from wallet
     Call this method when a member is removed from wallet
     
     :param: walletID for reference and memberID
     
     */
    func removeMemberFromWallet(_ walletID: String, memberID: String) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("WalletMembers/\(walletID)/\(memberID)").removeValue()
        UserManager.sharedInstance().removeWalletFromUser(memberID, walletID: walletID)
        
    }
}


class CurrencyManager {
    
    fileprivate static var singleTonInstance = CurrencyManager()
    
    static func sharedInstance() -> CurrencyManager {
        return singleTonInstance
    }
    
    func addCurrency(_ currency: Currency) {
        
        let ref = FIRDatabase.database().reference().child("Currencies").childByAutoId()
        
        let data = ["name": currency.name,
            "icon": currency.icon,
            "code": currency.code
        ]
        ref.setValue(data)
    }
    
}

class CategoryManager {
    
    fileprivate static var singleTonInstance = CategoryManager()
    
    static func sharedInstance() -> CategoryManager {
        return singleTonInstance
    }
    
    func addDefaultCategory(_ category: Category) {
        
        let ref = FIRDatabase.database().reference().child("DefaultCategories").childByAutoId()
        
        let data = ["name": category.name,
                    "icon": category.icon,
                    "color": category.color.stringRepresentation,
                    "isExpense": category.isExpense
            
        ] as [String : Any]
        ref.setValue(data)
    }
    
}
