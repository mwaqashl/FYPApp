
import Foundation
import Firebase

class TaskManager {
    
    fileprivate static var singleTonInstance = TaskManager()
    
    static func sharedInstance() -> TaskManager {
        return singleTonInstance
    }
    
    
    // Add a new task to Database ! required arg is task object
    func addNewTask(_ task: Task) {
        
        let ref = FIRDatabase.database().reference()
        let walletTasksRef = ref.child("Tasks/\(task.walletID)")
        let newTask = walletTasksRef.childByAutoId()
        task.id = newTask.key
        
        
        let data : NSMutableDictionary = [
            "title": task.title,
            "categoryID": task.categoryID,
            "amount": task.amount,
            "dueDate": task.dueDate.timeIntervalSince1970*1000,
            "startDate": task.startDate.timeIntervalSince1970*1000,
            "creator": task.creatorID,
            "status":0,
            "walletID":task.walletID,
        ]
        
        if task.comment != nil {
            data["comment"] = task.comment
        }
        
        
        newTask.setValue(data)
        
        for member in task.memberIDs {
            addMemberToTask(task.id, member: member)
        }
        
        for member in task.memberIDs {
            UserManager.sharedInstance().addTaskToUser(member, task: task)
        }
        
    }
    
    // Delete task from database // required arg is task object
    func deleteTask(_ task: Task) {
        let ref = FIRDatabase.database().reference()
        
        ref.child("Tasks/\(task.walletID)/\(task.id)").removeValue()
        
        for member in task.memberIDs {
            UserManager.sharedInstance().removeTaskFromUser(member, task: task)
        }
        ref.child("TasksMemberships/\(task.id)").removeValue()
        
        
    }
    
    // Update task in database // required arg is task object
    func updateTask(_ task: Task) {
        
        let ref = FIRDatabase.database().reference()
        
        
        let taskRef = ref.child("Tasks/\(task.walletID)/\(task.id)")
        
        var data : [String:Any] = [
            "title": task.title,
            "categoryID": task.categoryID,
            "amount": task.amount,
            "dueDate": task.dueDate.timeIntervalSince1970*1000,
            "creator": task.creatorID,
            "status":task.status.hashValue
        ]
        
        if task.comment != nil {
            data["comment"] = task.comment
        }
        
        
        taskRef.updateChildValues(data)
        
    }
    
    // When someone want to do or dont do any task ! required argument is object of that Task
    func taskStatusChanged(_ task: Task) {
        
        let ref = FIRDatabase.database().reference()
        let taskRef = ref.child("Tasks").child(task.walletID).child(task.id)
        
        taskRef.runTransactionBlock { (oldData) -> FIRTransactionResult in
            if var transData = oldData.value as? [String:Any] {
                
                guard let _ = transData["doneBy"] as? String else {
                    
                    if task.doneByID != nil {
                        transData["doneBy"] = task.doneByID! as AnyObject?
                    }
                    else {
                        transData.removeValue(forKey: "doneBy")
                    }
                    oldData.value = transData
                    return FIRTransactionResult.success(withValue: oldData)
                }
                
                if task.doneByID == nil {
                    transData.removeValue(forKey: "doneBy")
                }
                
                oldData.value = transData
                return FIRTransactionResult.success(withValue: oldData)
            }
            
            // Send local notification to user that someone has already doing this task !
            
            return FIRTransactionResult.success(withValue: oldData)
            
        }
        
    }
    
    func taskCompleted(task: Task) {
        
        let ref = FIRDatabase.database().reference()
        
        let taskRef = ref.child("Tasks").child(task.walletID).child(task.id)
        
        if task.status == .completed {
            taskRef.updateChildValues(["status" : 1])
        }
    }
    
    // Add a member to task, req args are taskID and userID of that member
    func addMemberToTask(_ taskID: String, member: String) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("TasksMemberships/\(taskID)/\(member)").setValue(true)
    }
    
    // Remove a member to task, req args are taskID and userID of that member
    func removeMemberFromTask(_ taskID: String, member: String) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("TasksMemberships/\(taskID)/\(member)").removeValue()
        
    }
    
    
}
