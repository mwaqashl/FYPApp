
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
    
    
    func createUser(email: String, password: String, user: CurrentUser, callback: @escaping (Error?) -> Void) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (firuser, err) in
            if err != nil {
                print(err!.localizedDescription)
                callback(err!)
                
            }
            else {
                
                let newUser = CurrentUser(id: firuser!.uid, email: email, userName: user.userName, imageURL: user.imageURL, birthdate: (user.birthdate?.timeIntervalSince1970)!*1000, deviceID: user.deviceID, gender: user.gender)
                
                self.authUser = newUser
                UserManager.sharedInstance().addNewUser(newUser)
                Resource.sharedInstance().currentUserId = newUser.getUserID()
                self.isAuthenticated = true
                callback(nil)
            }
        })
        
    }
    
    func signIn(email: String, password: String, callback: @escaping (Error?)->Void) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "Some Garbar ")
                self.isAuthenticated = false
                self.authUser = nil
                callback(error)
                return
                
            }
            else {
                
                FIRDatabase.database().reference().child("Users").child(user!.uid).observeSingleEvent(of: .value, with: { (snap) in
                    print(snap.value)
                    print(snap.key)
                    guard let data = snap.value as? NSDictionary else {
                        self.isAuthenticated = false
                        self.authUser = nil
                        
                        return
                        
                    }
                    
                    let thisUser = CurrentUser(id: user!.uid, email: email, userName: data["userName"] as! String, imageURL: data["image"] as! String, birthdate: data["birthDate"] as? Double, deviceID: data["deviceID"] as? String, gender: data["gender"] as! Int)
                    
                    self.isAuthenticated = true
                    self.authUser = thisUser
                    Resource.sharedInstance().currentUserId = thisUser.getUserID()

                    //for getting currentWalletID
                    if let walletID = defaultSettings.value(forKey: "walletID") as? String {
                        Resource.sharedInstance().currentWalletID = walletID
                    }else{
                        defaultSettings.setValue(thisUser.getUserID(), forKey: "walletID")
                        Resource.sharedInstance().currentWalletID = thisUser.getUserID()
                    }
                    
                    callback(nil)
//
//                    if (defaultSettings.value(forKey: "lastUserIDs") as! [String]).contains(thisUser.getUserID()){
//                        
//                        Resource.sharedInstance().currentUserId = user!.uid
//                        UserManager.sharedInstance().userLoggedIn(thisUser.getUserID())
//                        callback(nil)
//                        
//                    }else{
//                        
//                        Resource.sharedInstance().currentUserId = user!.uid
//                        HelperObservers.sharedInstance().getUserAndWallet({ (success) in
//                            if success {
//                                
//                                //did for quick logging in; refer to DefaultKeys for detail;
//                                var users = (defaultSettings.value(forKey: "lastUserIDs") as! [String])
//                                users.append(thisUser.getUserID())
//                                defaultSettings.setValue(users, forKey: "lastUserIDs")
//                                callback(nil)
//                                
//                            }else{
//                                
//                                self.authUser = thisUser
//                                callback(nil)
//                                
//                            }
//                        })
//                    }
//                    
                })

            }
            
        })
    }
    
}
