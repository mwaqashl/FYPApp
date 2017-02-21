
import Foundation
import Firebase

class TaskObserver {
    fileprivate let FIRKeys = ["Tasks", //0
        "TasksMemberships", //1
        "RecurringTasks", //2
        "payee", //3
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
        "recurringDays", //16
        "lastDueDate", //17
        "lastStartDate"] //18
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate static var singleInstance : TaskObserver?
    class func sharedInstance() -> TaskObserver {
        guard let instance = TaskObserver.singleInstance else {
            TaskObserver.singleInstance = TaskObserver()
            return singleInstance!
        }
        return instance
    }
    fileprivate var isObservingTasksOf : [String] = []
    fileprivate var _autoObserve : Bool = true
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
    func startObserving(TasksOf wallet : UserWallet){
        if !isObservingTasksOf.contains(wallet.id){
            observeTask(AddedOf : wallet)
            observeTask(DeletedOf: wallet)
            observeTask(UpdatedOf: wallet)
            isObservingTasksOf.append(wallet.id)
        }
    }
    func startObservingTask(_ task : Task){
        stopObservingTask(task)
        observeTaskMemberAdded(task);
        observeTaskMemberUpdated(task);
        observeTaskMemberRemoved(task);
    }
    func stopObservingTask(_ task :  Task){
        FIRDatabase.database().reference().child(FIRKeys[1]).child(task.id).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[2]).child(task.id).removeAllObservers()
    }
    func stopObserving(TasksOf wallet : UserWallet){
        FIRDatabase.database().reference().child(FIRKeys[0]).child(wallet.id).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[1]).child(wallet.id).removeAllObservers()
        FIRDatabase.database().reference().child(FIRKeys[2]).child(wallet.id).removeAllObservers()
        if isObservingTasksOf.contains(wallet.id){
            isObservingTasksOf.remove(at: isObservingTasksOf.index(of: wallet.id)!)
        }
    }
    fileprivate func observeTask(AddedOf wallet : UserWallet){
        let taskRef = ref.child(FIRKeys[0]).child(wallet.id)
        taskRef.observe(FIRDataEventType.childAdded, with:  { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let task = Task(taskID: snapshot.key,
                title: dict[self.FIRKeys[4]] as! String,
                categoryID: dict[self.FIRKeys[5]] as! String,
                amount: dict[self.FIRKeys[6]] as! Double,
                comment: dict[self.FIRKeys[7]] as? String,
                dueDate: (dict[self.FIRKeys[8]] as! Double)/1000,
                startDate: (dict[self.FIRKeys[9]] as! Double)/1000,
                creatorID: dict[self.FIRKeys[10]] as! String,
                status: getTaskStatus(dict[self.FIRKeys[13]] as! Int),
                doneByID: dict[self.FIRKeys[14]] as? String,
                payeeID: dict[self.FIRKeys[3]] as? String, memberIDs: [],
                walletID: dict[self.FIRKeys[15]] as! String)
            Resource.sharedInstance().tasks[snapshot.key] = task
            if self.autoObserve { self.observeTaskMemberAdded(task); self.observeTaskMemberUpdated(task); self.observeTaskMemberRemoved(task); }
            Delegate.sharedInstance().getTaskDelegates().forEach({ (taskDel) in
                taskDel.taskAdded(task)
            })
        })
        
    }
    fileprivate func observeTask(UpdatedOf wallet : UserWallet){
        let taskRef = ref.child(FIRKeys[0]).child(wallet.id)
        taskRef.observe(FIRDataEventType.childChanged, with:  { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let task = Resource.sharedInstance().tasks[snapshot.key]!
            task.title = dict[self.FIRKeys[4]] as! String
            task.categoryID = dict[self.FIRKeys[5]] as! String
            task.amount = dict[self.FIRKeys[6]] as! Double
            task.comment = dict[self.FIRKeys[7]] as? String
            task.dueDate = Date(timeIntervalSince1970 : (dict[self.FIRKeys[8]] as! Double)/1000)
            task.startDate = Date(timeIntervalSince1970 : (dict[self.FIRKeys[9]] as! Double)/1000)
            task.creatorID = dict[self.FIRKeys[10]] as! String
            task.status = getTaskStatus(dict[self.FIRKeys[13]] as! Int)
            task.doneByID = dict[self.FIRKeys[14]] as? String
            task.payeeID = dict[self.FIRKeys[3]] as? String
            Resource.sharedInstance().tasks[snapshot.key] = task
            Delegate.sharedInstance().getTaskDelegates().forEach({ (taskDel) in
                taskDel.taskUpdated(task)
            })
        })
        
    }
    fileprivate func observeTask(DeletedOf wallet : UserWallet){
        let taskRef = ref.child(FIRKeys[0]).child(wallet.id)
        taskRef.observe(FIRDataEventType.childRemoved, with:  { (snapshot) in
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
    }
    
    fileprivate func observeTaskMemberAdded(_ task: Task){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let taskRef = ref.child(FIRKeys[1]).child(task.id)
        taskRef.observe(FIRDataEventType.childAdded, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if snapshot.value as! Bool {
                Resource.sharedInstance().tasks[task.id]!.addMember(snapshot.key)
                Delegate.sharedInstance().getTaskMemberDelegates().forEach({ (taskMemDel) in
                    if let user = Resource.sharedInstance().users[snapshot.key] {
                        taskMemDel.memberAdded(user, task: task)
                    }else{
                        let user = User(id: snapshot.key, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
                        taskMemDel.memberAdded(user, task: task)
                    }
                })
                
                
            }
        })
    }
    
    fileprivate func observeTaskMemberUpdated(_ task: Task){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let taskRef = ref.child(FIRKeys[1]).child(task.id)
        taskRef.observe(FIRDataEventType.childChanged, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            if snapshot.value as! Bool {
                Resource.sharedInstance().tasks[task.id]?.addMember(snapshot.key)
                Delegate.sharedInstance().getTaskMemberDelegates().forEach({ (taskMemDel) in
                    if let user = Resource.sharedInstance().users[snapshot.key] {
                        taskMemDel.memberAdded(user, task: task)
                    }else{
                        let user = User(id: snapshot.key, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
                        taskMemDel.memberAdded(user, task: task)
                    }
                })
                
            }else{
                Resource.sharedInstance().tasks[task.id]?.removeMember(snapshot.key)
                guard let user = Resource.sharedInstance().users[snapshot.key] else {
                    return
                }
                Delegate.sharedInstance().getTaskMemberDelegates().forEach({ (taskMemDel) in
                    taskMemDel.memberLeft(user, task: task)
                })
                
            }
        })
    }
    
    fileprivate func observeTaskMemberRemoved(_ task: Task){ // For this you should implement user delegate and refresh using resource class when a user is added.
        let taskRef = ref.child(FIRKeys[1]).child(task.id)
        taskRef.observe(FIRDataEventType.childRemoved, with:  { (snapshot) in
            guard snapshot.value != nil else {
                return
            }
            Resource.sharedInstance().tasks[task.id]?.removeMember(snapshot.key)
                Delegate.sharedInstance().getTaskMemberDelegates().forEach({ (taskMemDel) in
                    if let user = Resource.sharedInstance().users[snapshot.key] {
                        taskMemDel.memberLeft(user, task: task)
                    }else{
                        let user = User(id: snapshot.key, email: "user@abc.com", userName: "Loading...", imageURL: "dp-male", gender: 2)
                        taskMemDel.memberLeft(user, task: task)
                    }
                })
            
        })
    }
}
