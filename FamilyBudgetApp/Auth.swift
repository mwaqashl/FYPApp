
import Foundation
import Firebase

 class Authentication {
    
    var authUser : CurrentUser?
    var isAuthenticated = false
    fileprivate static var singleTonInstance : Authentication?
    
    func logOutUser(callback: (Error?) -> Void) {
        do{
            try Auth.auth().signOut()
            isAuthenticated = false
            
            UserManager.sharedInstance().userLoggedOut(Resource.sharedInstance().currentUserId!)
            for wallet in Resource.sharedInstance().userWallets {
                
                BudgetObserver.sharedInstance().stopObserving(BudgetsOf: wallet.value)
                TransactionObserver.sharedInstance().stopObservingTransaction(ofWallet: wallet.key)
                TaskObserver.sharedInstance().stopObserving(TasksOf: wallet.value)
                ChatObserver.sharedInstance().stopObserving(wallet: wallet.value)
                WalletObserver.sharedInstance().stopObserving()
                UserObserver.sharedInstance().stopObserving()
            }
            Delegate.sharedInstance().removeAllDelegates()
            Resource.sharedInstance().reset()
            Database.database().reference().removeAllObservers()
            
            return callback(nil)
        }catch let error as NSError{
            showAlertWithOkayBtn(title: "Error", desc: error.localizedDescription)
            print(error.localizedDescription)
            return callback(error)
        }
    }
    
    class func sharedInstance() -> Authentication {
        guard let instance = singleTonInstance else{
            singleTonInstance = Authentication()
            return singleTonInstance!
        }
        return instance
        
    }
    
    
    func createUser(email: String, password: String, user: CurrentUser, callback: @escaping (Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (firuser, err) in
            if err != nil {
                showAlertWithOkayBtn(title: "Error", desc: err?.localizedDescription ?? "Some Error")
                print(err!.localizedDescription)
                callback(err!)
                
            }
            else {
                
                let newUser = CurrentUser(id: firuser!.uid, email: email, userName: user.userName, imageURL: user.imageURL, birthdate: (user.birthdate?.timeIntervalSince1970)!*1000, deviceID: user.deviceID, gender: user.gender)
                
                self.authUser = newUser
                UserManager.sharedInstance().addNewUser(newUser)
                Resource.sharedInstance().currentUserId = newUser.getUserID()
                HelperObservers.sharedInstance().startObserving()
                self.isAuthenticated = true
                callback(nil)
            }
        })
        
    }
    
    func signIn(email: String, password: String, callback: @escaping (Bool, Error?)->Void) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                showAlertWithOkayBtn(title: "Error", desc: error?.localizedDescription ?? "Some Error")
                print(error?.localizedDescription ?? "Some Garbar ")
                self.isAuthenticated = false
                self.authUser = nil
                callback(false,error)
                return
                
            }
            else {
                
                Database.database().reference().child("Users").child(user!.uid).observeSingleEvent(of: .value, with: { (snap) in
                    guard let data = snap.value as? NSDictionary else {
                        self.isAuthenticated = false
                        self.authUser = nil
                        return
                        
                    }
                    
                    let thisUser = CurrentUser(id: user!.uid, email: email, userName: data["userName"] as! String, imageURL: data["image"] as! String, birthdate: data["birthDate"] as? Double, deviceID: data["deviceID"] as? String, gender: data["gender"] as! Int)
                    
                    self.isAuthenticated = true
                    self.authUser = thisUser
                    Resource.sharedInstance().currentUserId = thisUser.getUserID()
                    Resource.sharedInstance().currentWalletID = thisUser.getUserID()
                    
                    if defaultSettings.value(forKey: "lastUserIDs") == nil {
                        let strarr : [String:String] = [:]
                        defaultSettings.set(strarr, forKey: "lastUserIDs")
                    }
                    
                    if (defaultSettings.value(forKey: "lastUserIDs") as! [String:String]).contains(where: { (this) -> Bool in
                        return this.0 == thisUser.getUserID()
                    }){
                        
                        Resource.sharedInstance().currentUserId = user!.uid
                        HelperObservers.sharedInstance().startObserving()
                        UserManager.sharedInstance().userLoggedIn(thisUser.getUserID())
                        callback(false, nil)
                        
                    }else{
                        
                        Resource.sharedInstance().currentUserId = user!.uid
                        HelperObservers.sharedInstance().startObserving()
                        UserManager.sharedInstance().userLoggedIn(thisUser.getUserID())
                        HelperObservers.sharedInstance().getUserAndWallet({ (success) in
                            if success {
                                
                                //did for quick logging in; refer to DefaultKeys for detail;
                                var users = (defaultSettings.value(forKey: "lastUserIDs") as! [String:String])
                                users[thisUser.getUserID()] = thisUser.getUserID()
                                defaultSettings.setValue(users, forKey: "lastUserIDs")
                                callback(false, nil)
                                
                            }else{
                                self.authUser = thisUser
                                callback(true, nil)
                                
                            }
                        })
                    }
//
                })

            }
            
        })
    }
    
    func signInSiliently(callback: @escaping (Bool, Bool)->Void) {
        
        if let user = Auth.auth().currentUser {
            Database.database().reference().child("Users").child(user.uid).observeSingleEvent(of: .value, with: { (snap) in
                guard let data = snap.value as? NSDictionary else {
                    self.isAuthenticated = false
                    self.authUser = nil
                    callback(false,false)
                    return
                }
                let thisUser = CurrentUser(id: user.uid, email: data["email"] as! String, userName: data["userName"] as! String, imageURL: data["image"] as! String, birthdate: data["birthDate"] as? Double, deviceID: data["deviceID"] as? String, gender: data["gender"] as! Int)
                self.isAuthenticated = true
                self.authUser = thisUser
                Resource.sharedInstance().currentUserId = thisUser.getUserID()
                Resource.sharedInstance().currentWalletID = thisUser.getUserID()
                HelperObservers.sharedInstance().startObserving()
                UserManager.sharedInstance().userLoggedIn(thisUser.getUserID())
                HelperObservers.sharedInstance().getUserAndWallet({ (success) in
                    if success {
                        var users = (defaultSettings.value(forKey: "lastUserIDs") as? [String:String]) ?? [:]
                        users[thisUser.getUserID()] = thisUser.getUserID()
                        defaultSettings.setValue(users, forKey: "lastUserIDs")
                        callback(true, false)
                        return
                        
                    }else{
                        self.authUser = thisUser
                        callback(true, true)
                        return
                    }
                })
                
            })
        }
        else {
            callback(false,false)
        }
    }
    
    func sendPasswordResetEmail(email: String, callback: @escaping (Bool)->Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            if err != nil {
                showAlertWithOkayBtn(title: "Error", desc: err?.localizedDescription ?? "Some Error")
                callback(false)
                return
            }
            callback(true)
        }
        
    }
    
    func resetPasswordofEmail(withVerificationCode code: String, newPassword pass:String, withcallback callback: @escaping (Bool)->Void) {
        
        
        Auth.auth().confirmPasswordReset(withCode: code, newPassword: pass) { (err) in
            if err == nil {
                callback(true)
                return
            }
            else {
                showAlertWithOkayBtn(title: "Error", desc: err?.localizedDescription ?? "Some Error")
                print(err?.localizedDescription ?? "some error in ", #function)
                callback(false)
            }
        }
    }
    
    func reAuthenticateUser(with email: String, password: String, with callback: @escaping (Bool)->Void) {
        
        let credentials = EmailAuthProvider.credential(withEmail: email, password: password)
        
        let user = Auth.auth().currentUser
        
        user?.reauthenticate(with: credentials, completion: { (err) in
            if err == nil {
                callback(true)
                return
            }
            else {
                showAlertWithOkayBtn(title: "Error", desc: err?.localizedDescription ?? "Some Error")
                print(err?.localizedDescription ?? "some error in ", #function)
                callback(false)
            }
        })
        
    }
    
    func updatePassword(newPassword: String, callback: @escaping (Bool)->Void) {
        
        let user = Auth.auth().currentUser
        
        user?.updatePassword(to: newPassword, completion: { (err) in
            if err == nil {
                callback(true)
                return
            }
            else {
                showAlertWithOkayBtn(title: "Error", desc: err?.localizedDescription ?? "Some Error")
                print(err?.localizedDescription ?? "some error in ", #function)
                callback(false)
            }
        })
    }
    
}

