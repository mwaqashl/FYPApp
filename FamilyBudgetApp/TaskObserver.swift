//
//  TaskObserver.swift
//  Penzy
//
//  Created by MacUser on 9/7/16.
//  Copyright © 2016 TechCollage. All rights reserved.
//

import Foundation
import Firebase

class TaskObserver {
    private let FIRKeys = ["Tasks", //0
        "TaskMemberships", //1
        "RecurringTasks", //2
        "payeeID", //3
        "title", //4
        "categoryID", //5
        "amount", //6
        "comment", //7
        "dueDate", //8
        "startDate", //9
        "creator", //10
        "venue", //11
        "pictures", //12
        "status", //13
        "doneBy", //14
        "walletID", //15
        "recurringDays"] //16
    private var ref = FIRDatabase.database().reference()
    private static var singleInstance : TaskObserver?
    class func sharedInstance() -> TaskObserver {
        guard let instance = TaskObserver.singleInstance else {
            TaskObserver.singleInstance = TaskObserver()
            return singleInstance!
        }
        return instance
    }
    private var _autoObserve : Bool = true
    var autoObserve : Bool {
        get { return _autoObserve } set {
            if newValue {
                Resource.sharedInstance().tasks.forEach({ (key, budget) in
                    TaskObserver.sharedInstance().startObservingTask(budget)
                })
            }else{
                Resource.sharedInstance().tasks.forEach({ (key, budget) in
                    TaskObserver.sharedInstance().stopObservingTask(budget)
                })
            }
            _autoObserve = newValue
        }
    }
    func startObserving(){
        observeTaskAdded()
        observeTaskDeleted()
        observeTaskUpdated()
    }
    func startObservingTask(task : Task){
        stopObservingTask(task)
        observeTaskMemberAdded(task);
        observeTaskMemberUpdated(task);
        observeTaskMemberRemoved(task);
    }
    func stopObservingTask(task :  Task){
        FIRDatabase.database().reference().child(FIRKeys[1]).child(task.id).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[2]).child(task.id).removeAllObservers()
    }
    func stopObserving(){
        FIRDatabase.database().reference().child(FIRKeys[0]).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[1]).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[2]).removeAllObservers()
    }
    private func observeTaskAdded(){
        let taskRef = ref.child(FIRKeys[0])
        taskRef.observeEventType(FIRDataEventType.ChildAdded, withBlock:  { (snapshot) in
            guard let dict = snapshot.value else {
                return
            }
            let task = Task(taskID: snapshot.key,
                title: dict[self.FIRKeys[4]] as! String,
                categoryID: dict[self.FIRKeys[5]] as! String,
                amount: dict[self.FIRKeys[6]] as! Double,
                comment: dict[self.FIRKeys[7]] as? String,
                dueDate: (dict[self.FIRKeys[8]] as! Double),
                startDate: (dict[self.FIRKeys[9]] as! Double),
                creatorID: dict[self.FIRKeys[10]] as! String,
                venue: dict[self.FIRKeys[11]] as? [String : AnyObject],
                pictureURLs: dict[self.FIRKeys[12]] as? [String],
                status: TaskStatus.Open,
                doneByID: dict[self.FIRKeys[14]] as? String,
                payeeID: dict[self.FIRKeys[3]] as? String, memberIDs: [],
                walletID: dict[self.FIRKeys[15]] as! String)
            Resource.sharedInstance().tasks[snapshot.key] = task
            if self.autoObserve { self.observeTaskMemberAdded(task); self.observeTaskMemberUpdated(task); self.observeTaskMemberRemoved(task); }
            Delegate.sharedInstance().getTaskDelegates().forEach({ (taskDel) in
                taskDel.taskAdded(task)
            })
        })
        
        let scheduledTaskRef = ref.child(FIRKeys[2])
        scheduledTaskRef.observeEventType(FIRDataEventType.ChildAdded , withBlock: { (snapshot) in
            guard let dict = snapshot.value else {
                return
            }
            let task = Task(taskID: snapshot.key,
                title: dict[self.FIRKeys[4]] as! String,
                categoryID: dict[self.FIRKeys[5]] as! String,
                amount: dict[self.FIRKeys[6]] as! Double,
                comment: dict[self.FIRKeys[7]] as? String,
                dueDate: (dict[self.FIRKeys[8]] as! Double),
                startDate: (dict[self.FIRKeys[9]] as! Double),
                creatorID: dict[self.FIRKeys[10]] as! String,
                venue: dict[self.FIRKeys[11]] as? [String : AnyObject],
                pictureURLs: dict[self.FIRKeys[12]] as? [String],
                status: getTaskStatus(dict[self.FIRKeys[13]] as! Int),
                doneByID: nil,
                payeeID: dict[self.FIRKeys[3]] as? String, memberIDs: [],
                walletID: dict[self.FIRKeys[15]] as! String)
            let recurringTask = RecurringTask(task: task, noOfDays: dict[self.FIRKeys[16]] as! Int)
            Resource.sharedInstance().recurringTasks[snapshot.key] = recurringTask
            if self.autoObserve { self.observeTaskMemberAdded(task); self.observeTaskMemberUpdated(task); self.observeTaskMemberRemoved(task); }
            Delegate.sharedInstance().getRucurringTaskDelegates().forEach({ (recurTaskDel) in
                recurTaskDel.scheduledTaskAdded(recurringTask)
            })
        })
    }
    private func observeTaskUpdated(){
        let taskRef = ref.child(FIRKeys[0])
        taskRef.observeEventType(FIRDataEventType.ChildChanged, withBlock:  { (snapshot) in
            guard let dict = snapshot.value else {
                return
            }
            let task = Resource.sharedInstance().tasks[snapshot.key]!
            task.title = dict[self.FIRKeys[4]] as! String
            task.categoryID = dict[self.FIRKeys[5]] as! String
            task.amount = dict[self.FIRKeys[6]] as! Double
            task.comment = dict[self.FIRKeys[7]] as? String
            task.dueDate = NSDate(timeIntervalSince1970 : (dict[self.FIRKeys[8]] as! Double)/1000)
            task.startDate = NSDate(timeIntervalSince1970 : (dict[self.FIRKeys[9]] as! Double)/1000)
            task.creatorID = dict[self.FIRKeys[10]] as! String
            task.venue = dict[self.FIRKeys[11]] as? [String : AnyObject]
            task.pictureURLs = dict[self.FIRKeys[12]] as? [String]
            task.status = getTaskStatus(dict[self.FIRKeys[13]] as! Int)
            task.doneByID = dict[self.FIRKeys[14]] as? String
            task.payeeID = dict[self.FIRKeys[3]] as? String
            Resource.sharedInstance().tasks[snapshot.key] = task
            Delegate.sharedInstance().getTaskDelegates().forEach({ (taskDel) in
                taskDel.taskUpdated(task)
            })
        })
        
        let scheduledTaskRef = ref.child(FIRKeys[2])
        scheduledTaskRef.observeEventType(FIRDataEventType.ChildChanged , withBlock: { (snapshot) in
            guard let dict = snapshot.value else {
                return
            }
            let recurringTask = Resource.sharedInstance().recurringTasks[snapshot.key]!
            recurringTask.title = dict[self.FIRKeys[4]] as! String
            recurringTask.categoryID = dict[self.FIRKeys[5]] as! String
            recurringTask.amount = dict[self.FIRKeys[6]] as! Double
            recurringTask.comment = dict[self.FIRKeys[7]] as? String
            recurringTask.dueDate = NSDate(timeIntervalSince1970 : (dict[self.FIRKeys[8]] as! Double)/1000)
            recurringTask.startDate = NSDate(timeIntervalSince1970 : (dict[self.FIRKeys[9]] as! Double)/1000)
            recurringTask.creatorID = dict[self.FIRKeys[10]] as! String
            recurringTask.venue = dict[self.FIRKeys[11]] as? [String : AnyObject]
            recurringTask.pictureURLs = dict[self.FIRKeys[12]] as? [String]
            recurringTask.payeeID = dict[self.FIRKeys[3]] as? String
            recurringTask.recurringDays = dict[self.FIRKeys[16]] as! Int
            Resource.sharedInstance().recurringTasks[snapshot.key] = recurringTask
            if self.autoObserve { self.observeTaskMemberAdded(recurringTask); self.observeTaskMemberUpdated(recurringTask); self.observeTaskMemberRemoved(recurringTask); }
            Delegate.sharedInstance().getRucurringTaskDelegates().forEach({ (recurTaskDel) in
                recurTaskDel.scheduledTaskUpdated(recurringTask)
            })
        })
    }
    private func observeTaskDeleted(){
        let taskRef = ref.child(FIRKeys[0])
        taskRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            guard let task = Resource.sharedInstance().tasks[snapshot.key] else {
                return
            }
            Resource.sharedInstance().tasks[snapshot.key] = nil
            Delegate.sharedInstance().getTaskDelegates().forEach({ (taskDel) in
                taskDel.taskDeleted(task)
            })
        })
        
        let scheduledTaskRef = ref.child(FIRKeys[2])
        scheduledTaskRef.observeEventType(FIRDataEventType.ChildRemoved , withBlock: { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            guard let task = Resource.sharedInstance().recurringTasks[snapshot.key] else {
                return
            }
            Resource.sharedInstance().recurringTasks[snapshot.key] = nil
            Delegate.sharedInstance().getRucurringTaskDelegates().forEach({ (taskDel) in
                taskDel.scheduledTaskDeleted(task)
            })
        })
    }
    private func observeTaskMemberAdded(task: Task){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let taskRef = ref.child(FIRKeys[1]).child(task.id)
        taskRef.observeEventType(FIRDataEventType.ChildAdded, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if snapshot.value as! Bool {
                if ((task as? RecurringTask) == nil) {
                    Resource.sharedInstance().tasks[task.id]!.addMember(snapshot.key)
                    guard let user = Resource.sharedInstance().users[snapshot.key] else {
                        return
                    }
                    Delegate.sharedInstance().getTaskMemberDelegates().forEach({ (taskMemDel) in
                        taskMemDel.memberAdded(user, task: task)
                    })
                }else{
                    Resource.sharedInstance().recurringTasks[task.id]?.addMember(snapshot.key)
                    guard let user = Resource.sharedInstance().users[snapshot.key] else {
                        return
                    }
                    Delegate.sharedInstance().getRecurringTaskMemberDelegates().forEach({ (taskMemDel) in
                        taskMemDel.memberAdded(user, task: task as! RecurringTask)
                    })
                }
                
                
            }
        })
    }
    private func observeTaskMemberUpdated(task: Task){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let taskRef = ref.child(FIRKeys[1]).child(task.id)
        taskRef.observeEventType(FIRDataEventType.ChildChanged, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if snapshot.value as! Bool {
                if ((task as? RecurringTask) == nil) {
                    Resource.sharedInstance().tasks[task.id]?.addMember(snapshot.key)
                    guard let user = Resource.sharedInstance().users[snapshot.key] else {
                        return
                    }
                    Delegate.sharedInstance().getTaskMemberDelegates().forEach({ (taskMemDel) in
                        taskMemDel.memberAdded(user, task: task)
                    })
                }else{
                    Resource.sharedInstance().recurringTasks[task.id]?.addMember(snapshot.key)
                    guard let user = Resource.sharedInstance().users[snapshot.key] else {
                        return
                    }
                    Delegate.sharedInstance().getRecurringTaskMemberDelegates().forEach({ (taskMemDel) in
                        taskMemDel.memberAdded(user, task: task as! RecurringTask)
                    })
                }
            }else{
                if ((task as? RecurringTask) == nil) {
                    Resource.sharedInstance().tasks[task.id]?.removeMember(snapshot.key)
                    guard let user = Resource.sharedInstance().users[snapshot.key] else {
                        return
                    }
                    Delegate.sharedInstance().getTaskMemberDelegates().forEach({ (taskMemDel) in
                        taskMemDel.memberLeft(user, task: task)
                    })
                }else{
                    Resource.sharedInstance().recurringTasks[task.id]?.removeMember(snapshot.key)
                    guard let user = Resource.sharedInstance().users[snapshot.key] else {
                        return
                    }
                    Delegate.sharedInstance().getRecurringTaskMemberDelegates().forEach({ (taskMemDel) in
                        taskMemDel.memberLeft(user, task: task as! RecurringTask)
                    })
                }
            }
            
        })
    }
    private func observeTaskMemberRemoved(task: Task){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let taskRef = ref.child(FIRKeys[1]).child(task.id)
        taskRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if ((task as? RecurringTask) == nil) {
                Resource.sharedInstance().tasks[task.id]?.removeMember(snapshot.key)
                guard let user = Resource.sharedInstance().users[snapshot.key] else {
                    return
                }
                Delegate.sharedInstance().getTaskMemberDelegates().forEach({ (taskMemDel) in
                    taskMemDel.memberLeft(user, task: task)
                })
            }else{
                Resource.sharedInstance().recurringTasks[task.id]?.removeMember(snapshot.key)
                guard let user = Resource.sharedInstance().users[snapshot.key] else {
                    return
                }
                Delegate.sharedInstance().getRecurringTaskMemberDelegates().forEach({ (taskMemDel) in
                    taskMemDel.memberLeft(user, task: task as! RecurringTask)
                })
            }
            
        })
    }
}