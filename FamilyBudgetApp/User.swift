
import Foundation
import Firebase

enum SubscriptionType {
    case none, monthly, yearly
}
let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
class User {
    fileprivate var id : String
    fileprivate var email : String
    var userName : String
    var imageURL : String
    var image  : UIImage?
    var gender : Int
    
    init(id : String, email : String, userName : String, imageURL : String, gender: Int) {
        self.id = id
        self.email = email
        self.userName = userName
        self.imageURL = imageURL
        self.gender = gender
    }
    
    func getUserID() -> String {
        return id
    }
    
    func getUserEmail() -> String {
        return email
    }
    
    func getImage(_ completion : @escaping (Data) -> ()) {
        if self.imageURL == "dp-male" || self.imageURL == "dp-female" {
            completion(UIImagePNGRepresentation(UIImage(named: self.imageURL)!)!)
            return
        }
        let fileManager = FileManager.default
        let imageNSURL = url.appendingPathComponent("images/userImages/\(self.id)/\(self.imageURL)")
        if fileManager.fileExists(atPath: imageNSURL.absoluteString) {
            let data = try? Data(contentsOf: imageNSURL)
            completion(data!)
        }else{
            let imageRef = FIRStorage.storage().reference(forURL: "gs://familybudgetapp-6f637.appspot.com").child("images").child("userImages").child(self.id).child(self.imageURL)
            imageRef.write(toFile: imageNSURL, completion: { (url, error) in
                guard error == nil else {
                    return
                }
                let data = try! Data(contentsOf: url!)
                completion(data)
            })
        }
    }
}

class CurrentUser : User {
    var birthdate : Date?
    var deviceID : String?
    
    var wallets : [Wallet]{
        var _wallets : [Wallet] = []
        for (key,value) in Resource.sharedInstance().userWallets {
            if walletIDs.contains(key) {
                _wallets.append(value)
            }
        }
        return _wallets
    }
    fileprivate var walletIDs : [String]{
        var _walletIDs : [String] = []
        Resource.sharedInstance().userWallets.forEach { (key, wallets) in
            if wallets.memberTypes[self.id] != nil {
                _walletIDs.append(key)
            }
        }
        return _walletIDs
    }
    fileprivate var tasks : [Task] {
        var _tasks : [Task] = []
        for (key,value) in Resource.sharedInstance().tasks {
            if taskIDs.contains(key) {
                _tasks.append(value)
            }
        }
        return _tasks
    }
    fileprivate var taskIDs : [String] {
        var _taskIDs : [String] = []
        Resource.sharedInstance().tasks.forEach { (key, tasks) in
            if tasks.memberIDs.contains(self.id) {
                _taskIDs.append(key)
            }
        }
        return _taskIDs
    }
    
    
    
    init(id : String, email : String, userName : String, imageURL : String, birthdate : Double?, deviceID : String?, gender: Int) {
        if birthdate != nil {
            self.birthdate = Date(timeIntervalSince1970: birthdate!)
        }
        self.deviceID = deviceID != nil ? deviceID! : ""
        super.init(id: id, email: email, userName: userName, imageURL: imageURL, gender: gender)
    }
    
    
    func setDevice(_ deviceID: String) {
        self.deviceID = deviceID
    }
    
    
}

protocol UserDelegate {
    func userDetailsAdded(_ user: CurrentUser)
    func userDetailsUpdated(_ user: CurrentUser)
    func userAdded(_ user : User)
    func userUpdated(_ user : User)
}
