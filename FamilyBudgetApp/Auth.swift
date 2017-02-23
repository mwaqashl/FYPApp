
import Foundation
import Firebase

 class Auth {

    
    var authUser : CurrentUser?
    var isAuthenticated = false
    fileprivate static var singleTonInstance : Auth?
    
    func logOutUser() -> NSError? {
        do{
            try FIRAuth.auth()?.signOut()
            isAuthenticated = false
            Resource.sharedInstance().reset()
            FIRDatabase.database().reference().removeAllObservers()
            return nil
        }catch let error as NSError{
            print(error.localizedDescription)
            return error
        }
    }
    
    class func sharedInstance() -> Auth {
        guard let instance = singleTonInstance else{
            singleTonInstance = Auth()
            return singleTonInstance!
        }
        return instance
    }
    
    
    func createUser(email: String, password: String, user: CurrentUser, callback: @escaping (Bool)->Void) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (firuser, err) in
            if err != nil {
                print(err!.localizedDescription)
                callback(false)
                
            }
            else {
                
                let newUser = CurrentUser(id: firuser!.uid, email: email, userName: user.userName, imageURL: user.imageURL, birthdate: (user.birthdate?.timeIntervalSince1970)!*1000, deviceID: user.deviceID, gender: user.gender)
                
                self.authUser = newUser
                UserManager.sharedInstance().addNewUser(newUser)
                self.isAuthenticated = true
                callback(true)
            }
        })
        
    }
    
    func signIn(email: String, password: String, callback: @escaping (CurrentUser?)->Void) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "Some Garbar ")
                self.isAuthenticated = false
                self.authUser = nil
                callback(nil)
                
                
            }
            else {
                
                FIRDatabase.database().reference().child("UserInfo").child(user!.uid).observeSingleEvent(of: .value, with: { (snap) in
                    
                    guard let data = snap.value as? [String:Any] else {
                        self.isAuthenticated = false
                        self.authUser = nil
                        
                        return
                        
                    }
                    
                    let thisUser = CurrentUser(id: user!.uid, email: email, userName: data["userName"] as! String, imageURL: data["image"] as! String, birthdate: data["birthDate"] as? Double, deviceID: data["deviceID"] as? String, gender: data["gender"] as! Int)
                    
                    self.isAuthenticated = true
                    self.authUser = thisUser
                    
                    callback(thisUser)
                    
                })
                
            }
        })
    }
    
    
    
        // GoolgeSignIn Delegate Functions
//    internal func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//        do{
//            try FIRAuth.auth()?.signOut()
//            Resource.sharedInstance().reset()
//        }catch let error as NSError {
//            print(error)
//        }
//    }
//    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        // sign in to firebase using credentials
//        if error != nil {
//            print(error.localizedDescription)
//            return
//        }
//        defaultSettings.setValue("g", forKey: "authProvider")
//        let authentication = user.authentication
//        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,accessToken: (authentication?.accessToken)!)
//        FIRAuth.auth()?.signIn(with: credential, completion: { (firuser, error) in
//            self.isAuthenticated = true
//            if error != nil {
//                print(error?.localizedDescription)
//                return
//            }
//            
//            let newUser = CurrentUser(id: firuser!.uid, email: user.profile.email!, userName: firuser!.displayName!, imageURL: user.profile.imageURL(withDimension: UInt.max).absoluteString, birthdate: nil, deviceIDs: nil, subscriptionType: .none, lastSubscription: nil)
//            
//            //for getting currentWalletID
//            if var userDict = defaultSettings.value(forKey: "walletID") as? [String: String] {
//                if let walletID = userDict[newUser.getUserID()]{
//                    Resource.sharedInstance().currentWalletID = walletID
//                }else{
//                    Resource.sharedInstance().currentWalletID = newUser.getUserID()
//                    userDict[newUser.getUserID()] = newUser.getUserID()
//                    defaultSettings.setValue(userDict, forKey: "walletID")
//                }
//            }else{
//                let userDict = [newUser.getUserID() : newUser.getUserID()]
//                defaultSettings.setValue(userDict, forKey: "walletID")
//                Resource.sharedInstance().currentWalletID = newUser.getUserID()
//            }
//            
//            
//            if (defaultSettings.value(forKey: "lastUserIDs") as! [String]).contains(newUser.getUserID()){
//                
//                Resource.sharedInstance().currentUserId = firuser!.uid
//                UserManager.sharedInstance().userLoggedIn(newUser.getUserID())
//                self.callback?(false)
//                
//            }else{
//                
//                Resource.sharedInstance().currentUserId = firuser!.uid
//                HelperObservers.sharedInstance().getUserAndWallet({ (success) in
//                    if success {
//                        
//                        //did for quick logging in; refer to DefaultKeys for detail;
//                        var users = (defaultSettings.value(forKey: "lastUserIDs") as! [String])
//                        users.append(newUser.getUserID())
//                        defaultSettings.setValue(users, forKey: "lastUserIDs")
//                        self.callback?(false)
//                        
//                    }else{
//                        
//                        self.authUser = newUser
//                        self.callback?(true)
//                        
//                    }
//                })
//            }
//            
//            
//        })
//        
//    }
    
    
    
    
}
