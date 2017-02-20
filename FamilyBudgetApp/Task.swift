

//  Task.swift
//  AccBook
//
//  Created by MacUser on 8/18/16.
//  Copyright © 2016 Collage. All rights reserved.
//

import Foundation
import Firebase //only for storage

enum TaskStatus {
    case Open,Completed
}

class Task {
    
    var id : String
    var title: String
    var category: Category? {
        return Resource.sharedInstance().categories[categoryID]
    }
    var categoryID: String
    var amount: Double
    var comment: String?
    var dueDate: NSDate
    var startDate: NSDate
    var creator: User? {
        return Resource.sharedInstance().users[creatorID]
    }
    var creatorID: String
    var venue: [String : AnyObject]? // name,lat,long
    var pictureURLs: [String]?
    var status: TaskStatus
    var doneBy: User? {
        return doneByID != nil ? Resource.sharedInstance().users[doneByID!] : nil
    }
    var doneByID: String?
    var payee: User? {
        return payeeID != nil ? Resource.sharedInstance().users[payeeID!] : nil
    }
    var payeeID: String?
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
    
    init(taskID : String, title: String, categoryID: String, amount: Double, comment: String?, dueDate: Double, startDate: Double, creatorID: String, venue: [String:AnyObject]?, pictureURLs: [String]?, status: TaskStatus, doneByID: String?, payeeID: String?, memberIDs: [String], walletID: String) {
        self.amount = amount
        self.categoryID = categoryID
        self.comment = comment
        self.creatorID = creatorID
        self.doneByID = doneByID
        self.dueDate = NSDate(timeIntervalSince1970: dueDate/1000)
        self.payeeID = payeeID
        self.pictureURLs = pictureURLs
        self.startDate = NSDate(timeIntervalSince1970: startDate/1000)
        self.status = status
        self.id = taskID
        self.title = title
        self.venue = venue
        self.memberIDs = memberIDs
        self.walletID = walletID
    }
    func addMember(memberId : String){
        if !memberIDs.contains(memberId) {
            memberIDs.append(memberId)
        }
    }
    func getMemberIDs() -> [String] {
        return memberIDs
    }
    func removeMember(memberId : String){
        for i in 0..<memberIDs.count {
            if memberIDs[i] == memberId {
                memberIDs.removeAtIndex(i)
                return
            }
        }
    }
    
    func getImage(urlS: String, completion : (NSData) -> ()) {
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
        let imageNSURL = url.URLByAppendingPathComponent("images/userImages/\(self.id)/\(urlS)")
        if fileManager.fileExistsAtPath(imageNSURL.absoluteString) {
            let data = NSData(contentsOfURL: imageNSURL)
            completion(data!)
        }else{
            let imageRef = FIRStorage.storage().referenceForURL("gs://penzy-120d0.appspot.com").child("images").child("taskImages").child(self.id).child(urlS)
            imageRef.writeToFile(imageNSURL, completion: { (urlRef, error) in
                guard error == nil else {
                    return
                }
                let data = NSData(contentsOfURL: urlRef!)!
                completion(data)
            })
        }
    }
}


class RecurringTask: Task {
    
    var recurringDays: Int
    
    init(task: Task, noOfDays: Int) {
        self.recurringDays = noOfDays
        super.init(taskID: task.id, title: task.title, categoryID: task.categoryID, amount: task.amount, comment: task.comment, dueDate: task.dueDate.timeIntervalSince1970, startDate: task.startDate.timeIntervalSince1970, creatorID: task.creatorID, venue: task.venue, pictureURLs: task.pictureURLs, status: task.status, doneByID: task.doneByID, payeeID: task.payeeID, memberIDs: task.memberIDs, walletID: task.walletID)
    }
}

protocol TaskDelegate {
    func taskAdded(task: Task)
    func taskUpdated(task: Task)
    func taskDeleted(task: Task)
}
protocol ScheduledTaskDelegate {
    func scheduledTaskAdded(task : RecurringTask)
    func scheduledTaskUpdated(task: RecurringTask)
    func scheduledTaskDeleted(task: RecurringTask)
}
protocol TaskMemberDelegate {
    func memberAdded(member : User, task : Task)
    func memberLeft(member : User, task : Task)
}
protocol ScheduledTaskMemberDelegate {
    func memberAdded(member : User, task : RecurringTask)
    func memberLeft(member : User, task : RecurringTask)
}