//
//  TaskManager.swift
//  Penzy
//
//  Created by Waqas Hussain on 30/08/2016.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation
import Firebase

class TaskManager {
    
    private static var singleTonInstance = TaskManager()
    
    static func sharedInstance() -> TaskManager {
        return singleTonInstance
    }
    
    
    // Add a new task to Database ! required arg is task object
    func addNewTask(task: Task) {
        
        let ref = FIRDatabase.database().reference()
        let walletTasksRef = ref.child("Tasks")
        let newTask = walletTasksRef.childByAutoId()
        task.id = newTask.key
        
        
        let data : NSMutableDictionary = [
            "title": task.title,
            "categoryID": task.categoryID,
            "amount": task.amount,
            "dueDate": task.dueDate.timeIntervalSince1970*1000,
            "startDate ": task.startDate.timeIntervalSince1970*1000,
            "creator": task.creatorID,
            "status":0,
            "walletID":task.walletID
        ]
        
        if task.venue != nil {
            
            let venue : NSMutableDictionary = [
                "name": task.venue!["name"]!
            ]
            
            if task.venue!["lat"] != nil {
                venue["lat"] = task.venue!["lat"]!
                venue["long"] = task.venue!["long"]!
            }
            
            data["venue"] = venue
        }

        
        if task.payeeID != nil {
            data["payee"] = task.payeeID
        }
        
        if task.pictureURLs != nil {
            data["pictureURLs"] = task.pictureURLs
        }
        
        newTask.setValue(data)
        
        
        // If Task is recurring Add it to recurring task
        if let task = task as? RecurringTask {
            data.removeObjectsForKeys(["dueDate","startDate","status"])
            data["lastDueDate"] = task.dueDate.timeIntervalSince1970*1000
            data["lastStartDate"] = task.startDate.timeIntervalSince1970*1000
            data["recurringDays"] = task.recurringDays
            
            let recurringTask = ref.child("RecurringTasks").childByAutoId()
            recurringTask.setValue(data)
            
            for member in task.memberIDs {
                addMemberToTask(recurringTask.key, member: member)
            }
            
        }
        
        for member in task.memberIDs {
            addMemberToTask(task.id, member: member)
        }
        
        
        for member in task.memberIDs {
            UserManager.sharedInstance().addTaskToUser(member, task: task)
        }
        
    }
    
    // Delete task from database // required arg is task object
    func deleteTask(task: Task) {
        let ref = FIRDatabase.database().reference()
        
        if task is RecurringTask {
            ref.child("RecurringTasks/\(task.id)").removeValue()
            ref.child("TasksMemberships/\(task.id)").removeValue()
        }
        else {
            ref.child("Tasks/\(task.walletID)/\(task.id)").removeValue()
            
            for member in task.memberIDs {
                UserManager.sharedInstance().removeTaskFromUser(member, task: task)
            }
            ref.child("TasksMemberships/\(task.id)").removeValue()
        }
        
    }
    
    // Update task in database // required arg is task object
    func updateTask(task: Task) {
        
        let ref = FIRDatabase.database().reference()

        if task is RecurringTask {
            
            let taskRef = ref.child("RecurringTasks/\(task.id)")
            
            let data : NSMutableDictionary = [
                "title": task.title,
                "categoryID": task.categoryID,
                "startDate": task.startDate.timeIntervalSince1970*1000,
                "dueDate": task.dueDate.timeIntervalSince1970*1000,
                "amount": task.amount,
                "creator": task.creatorID,
                "status":task.status.hashValue,
                "recurringDays":(task as! RecurringTask).recurringDays
            ]
            
            if task.venue != nil {
                
                let venue : NSMutableDictionary = [
                    "name": task.venue!["name"]!
                ]
                
                if task.venue!["lat"] != nil {
                    venue["lat"] = task.venue!["lat"]!
                    venue["long"] = task.venue!["long"]!
                }
                
                data["venue"] = venue
            }
            
            if task.payeeID != nil {
                data["payee"] = task.payeeID
            }
            
            if task.pictureURLs != nil {
                data["pictureURLs"] = task.pictureURLs
            }
            
            taskRef.updateChildValues(data as [NSObject : AnyObject])
            
        }
        else {
            
            let taskRef = ref.child("Tasks/\(task.id)")
            
            let data : NSMutableDictionary = [
                "title": task.title,
                "categoryID": task.categoryID,
                "amount": task.amount,
                "lastStartDate": task.startDate.timeIntervalSince1970*1000,
                "lastDueDate": task.dueDate.timeIntervalSince1970*1000,
                "creator": task.creatorID,
                "status":task.status.hashValue
            ]
            
            if task.venue != nil {
                
                let venue : NSDictionary = [
                    "name": task.venue!["name"]!,
                    "lat": task.venue!["lat"]!,
                    "long": task.venue!["long"]!
                ]
                data["venue"] = venue
            }
            
            if task.payeeID != nil {
                data["payee"] = task.payeeID
            }
            
            if task.pictureURLs != nil {
                data["pictureURLs"] = task.pictureURLs
            }

            taskRef.updateChildValues(data as [NSObject : AnyObject])
        }
        
    }
    
    // When someone want to do or dont do any task ! required argument is object of that Task
    func taskStatusChanged(task: Task) {
        
        let ref = FIRDatabase.database().reference()
        let taskRef = ref.child("Task").child(task.id)
        
        taskRef.runTransactionBlock { (oldData) -> FIRTransactionResult in
            
            if var transData = oldData.value as? [String:AnyObject] {
                
                guard let _ = transData["doneBy"] as? String else {
                    
                    if task.doneByID != nil {
                        transData["doneBy"] = task.doneByID!
                    }
                    else {
                        transData["doneBy"] = ""
                    }
                    oldData.value = transData
                    return FIRTransactionResult.successWithValue(oldData)
                }
                
            }
            
            // Send local notification to user that someone has already doing this task !
            
            return FIRTransactionResult.successWithValue(oldData)
            
        }
        
    }
    
    // Add a member to task, req args are taskID and userID of that member
    func addMemberToTask(taskID: String, member: String) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("TasksMemberships/\(taskID)").setValue([member : false])
    }
    
    // Remove a member to task, req args are taskID and userID of that member
    func removeMemberFromTask(taskID: String, member: String) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("TasksMemberships/\(taskID)/\(member)").removeValue()
        
    }
}