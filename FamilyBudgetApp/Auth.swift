
import Foundation
import Firebase

 class Auth {
    
    var authUser : CurrentUser?
    var isAuthenticated = false
    fileprivate static var singleTonInstance : Auth?
    
    func logOutUser(callback: (Error?) -> Void) {
        do{
            try FIRAuth.auth()?.signOut()
            isAuthenticated = false
            Resource.sharedInstance().reset()
            FIRDatabase.database().reference().removeAllObservers()
            return callback(nil)
        }catch let error as NSError{
            print(error.localizedDescription)
            return callback(error)
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
    
    func signIn(email: String, password: String, callback: @escaping (Bool, Error?)->Void) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "Some Garbar ")
                self.isAuthenticated = false
                self.authUser = nil
                callback(false,error)
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
                    Resource.sharedInstance().currentWalletID = thisUser.getUserID()
                    
                    if defaultSettings.value(forKey: "lastUserIDs") == nil {
                        let strarr : [String:String] = [:]
                        defaultSettings.set(strarr, forKey: "lastUserIDs")
                    }
                    
                    if (defaultSettings.value(forKey: "lastUserIDs") as! [String:String]).contains(where: { (this) -> Bool in
                        return this.0 == thisUser.getUserID()
                    }){
                        
                        Resource.sharedInstance().currentUserId = user!.uid
                        UserManager.sharedInstance().userLoggedIn(thisUser.getUserID())
                        callback(false, nil)
                        
                    }else{
                        
                        Resource.sharedInstance().currentUserId = user!.uid
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
    
}

