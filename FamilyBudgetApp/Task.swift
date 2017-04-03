

import Foundation
import Firebase //only for storage

enum TaskStatus {
    case open,completed
}

class Task {
    
    var id : String
    var title: String
    var category: Category? {
        if let category = Resource.sharedInstance().categories[categoryID]{
            return category
        }
        return Category(id: categoryID, name: "Loading...", icon: "ꀔ", isDefault: true, isExpense: true, color: textColor.stringRepresentation)
    }
    var categoryID: String
    var amount: Double
    var comment: String?
    var dueDate: Date
    var startDate: Date
    var creator: User? {
        if let user = Resource.sharedInstance().users[creatorID] {
            return user
        }
        return User(id: creatorID, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
    }
    var creatorID: String
    var status: TaskStatus
    var doneBy: User? {
        if let user = (doneByID != nil ? Resource.sharedInstance().users[doneByID!] : nil){
            return user
        }
        if let doneByid = doneByID {
            return User(id: doneByid, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
        }
        return nil
    }
    var doneByID: String?
    var members: [User] {
        var _members :[User] = []
        for(key,value) in Resource.sharedInstance().users {
            if memberIDs.contains(key) {
                _members.append(value)
            }
        }
        return _members
    }
    var memberIDs: [String]
    var walletID: String
    var wallet : UserWallet? {
        return Resource.sharedInstance().userWallets[walletID]
    }
    
    var timeLeft = 0.0 {
        didSet {
            timeLeftObserver?(self.timeLeft,self)
        }
    }
    var timeLeftObserver : ((Double, Task) -> Void)?

    
    init(taskID : String, title: String, categoryID: String, amount: Double, comment: String?, dueDate: Double, startDate: Double, creatorID: String, status: TaskStatus, doneByID: String?,  memberIDs: [String], walletID: String) {
        self.amount = amount
        self.categoryID = categoryID
        self.comment = comment
        self.creatorID = creatorID
        self.doneByID = doneByID
        self.dueDate = Date(timeIntervalSince1970: dueDate)
        self.startDate = Date(timeIntervalSince1970: startDate)
        self.status = status
        self.id = taskID
        self.title = title
        self.memberIDs = memberIDs
        self.walletID = walletID
    }
    
    func addMember(_ memberId : String){
        if !memberIDs.contains(memberId) {
            memberIDs.append(memberId)
        }
    }
    
    func getMemberIDs() -> [String] {
        return memberIDs
    }
    
    func removeMember(_ memberId : String){
        for i in 0..<memberIDs.count {
            if memberIDs[i] == memberId {
                memberIDs.remove(at: i)
                return
            }
        }
    }
    
    @objc func startObservingTimeLeft() {
        
        print("Start Observing timeleft")
        let times : [Double] = [5*60, 10*60, 30*60, 60*60, 24*60*60, 7*24*60*60, 7*24*60*60, 31*24*60*60, 365*24*60*60]
        
        timeLeft = dueDate.timeIntervalSince(Date())
        
        var timeInterval : Double = 0
        
        var index = 0
        for i in 0..<times.count {
            if timeLeft < times[i] {
                break
            }
            index = i
        }
        
        if index > 0 {
            let div = Int(timeLeft/times[index])
            let rem = timeLeft - Double(div)*(times[index])
            
            timeInterval = rem
        }
        else {
            timeInterval = timeLeft
        }
        
        if timeInterval > 0 {
            print("Timer Start of ", timeInterval)
            Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(Task.startObservingTimeLeft), userInfo: nil, repeats: false)
        }
        
    }
    
    func getImage(_ urlS: String, completion : @escaping (Data) -> ()) {
        if urlS == "dp-male" || urlS == "dp-female" {
            completion(UIImagePNGRepresentation(UIImage(named: urlS)!)!)
        }
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let imageNSURL = url.appendingPathComponent("images/userImages/\(self.id)/\(urlS)")
        if fileManager.fileExists(atPath: imageNSURL.absoluteString) {
            let data = try? Data(contentsOf: imageNSURL)
            completion(data!)
        }else{
            let imageRef = FIRStorage.storage().reference(forURL: "gs://familybudgetapp-6f637.appspot.com").child("images").child("taskImages").child(self.id).child(urlS)
            imageRef.write(toFile: imageNSURL, completion: { (urlRef, error) in
                guard error == nil else {
                    return
                }
                let data = try! Data(contentsOf: urlRef!)
                completion(data)
            })
        }
    }
}

protocol TaskDelegate {
    func taskAdded(_ task: Task)
    func taskUpdated(_ task: Task)
    func taskDeleted(_ task: Task)
}

protocol TaskMemberDelegate {
    func memberAdded(_ member : User, task : Task)
    func memberLeft(_ member : User, task : Task)
}
