
import Foundation
import Firebase
import UIKit

enum SubscriptionType {
    case none, monthly, yearly
}
let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
class User {
    fileprivate var id : String
    fileprivate var email : String
    var userName : String
    var imageURL : String
    var image  : UIImage? {
        
        if self.imageURL == "dp-male" || self.imageURL == "dp-female" {
            return self.imageURL == "dp-male" ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female")
        }
        let fileManager = FileManager.default
        let imageNSURL = url.appendingPathComponent("images/userImages/\(self.id)/\(self.imageURL)")
        print("url", url.absoluteString)
        if fileManager.fileExists(atPath: imageNSURL.path) {
            let data = try? Data(contentsOf: imageNSURL)
            
            guard let image = UIImage(data: data!) else {
                return nil
            }
            
            return image
        }else{
            let imageRef = Storage.storage().reference(forURL: "gs://familybudgetapp-6f637.appspot.com").child("images").child("userImages").child(self.id).child(self.imageURL)
            
            imageRef.getData(maxSize: 2*1024*1024, completion: { (data, err) in
                
                if err != nil {
                    print("Error", err?.localizedDescription)
                    return
                }
                guard let img = UIImage(data: data!) else {
                    return
                }
                
                let success = fileManager.createFile(atPath: imageNSURL.path, contents: data, attributes: nil)
                print(success)
                self.imageCallback(img)
                
            })
        }
        return nil
    }
    
    var gender : Int
    
    var imageCallback : (UIImage)->Void = {
        image in
    }
    
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
    
    func uploadImage(image: UIImage, with callback: @escaping (Bool)->Void) {
        
        if image == #imageLiteral(resourceName: "dp-female") || image == #imageLiteral(resourceName: "dp-male") {
            self.imageURL = image == #imageLiteral(resourceName: "dp-male") ? "dp-male" : "dp-female"
            callback(true)
            return
        }
        
        var id = UUID.init().uuidString
        let r = id.startIndex..<id.index(id.startIndex, offsetBy: 5)
        id = id.substring(with: r)
        let imageRef = Storage.storage().reference(forURL: "gs://familybudgetapp-6f637.appspot.com").child("images").child("userImages").child(Auth.auth().currentUser!.uid).child("\(id).jpg")
        
        guard let data = UIImageJPEGRepresentation(image, 0.1) else {
            callback(false)
            return
            
        }
        
        imageRef.putData(data, metadata: nil) { (metaData, err) in
            
            if err != nil {
                callback(false)
                showAlertWithOkayBtn(title: "Error", desc: err?.localizedDescription ?? "Some Error Occurred")
                return
            }
            
            self.imageURL = "\(id).jpg"
            UserManager.sharedInstance().updateUserState(self)
            callback(true)
            
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
