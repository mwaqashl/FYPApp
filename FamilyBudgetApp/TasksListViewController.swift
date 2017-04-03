//
//  TasksListViewController.swift
//  test
//
//  Created by mac on 3/27/17.
//  Copyright © 2017 UIT. All rights reserved.
//

import UIKit

class TasksListViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource,TaskDelegate , WalletMemberDelegate{

    @IBOutlet weak var SegmentBtn: UISegmentedControl!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var tableview: UITableView!
    
    var deleteIndex : IndexPath?
    
    var taskskey = [String]()
    var selectedrow : Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        
        Delegate.sharedInstance().addTaskDelegate(self)
        Delegate.sharedInstance().addWalletMemberDelegate(self)

        UserObserver.sharedInstance().startObserving()          // home page pr lage ga..:D
        TaskObserver.sharedInstance().startObserving(TasksOf: Resource.sharedInstance().currentWallet!)
        
        
        for key in Resource.sharedInstance().tasks.keys {
            taskskey.append(key)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(taskskey.count)
        return taskskey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasks") as! TaskTableViewCell
        let tasks = Resource.sharedInstance().tasks[taskskey[indexPath.row]]
        cell.Title.text = tasks!.title
        cell.icon.text = tasks!.category!.icon
        cell.status.layer.backgroundColor = tasks!.status == .open ? UIColor.green.cgColor : UIColor.red.cgColor
        
        cell.icon.textColor = tasks!.category!.color
        cell.icon.layer.cornerRadius = cell.icon.layer.frame.width/2
        cell.icon.layer.borderWidth = 1
        cell.icon.layer.borderColor = cell.icon.textColor.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedrow = indexPath.row
        performSegue(withIdentifier: "Description", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Description" {
            let destination = segue.destination as! AddTaskViewController
            destination.task = Resource.sharedInstance().tasks[taskskey[selectedrow!]]
            destination.isNew = false
        }
        else if segue.identifier == "addTask" {
            let destination = segue.destination as! AddTaskViewController
            destination.isNew = true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let tasks = Resource.sharedInstance().tasks[taskskey[indexPath.row]]
        
        if Resource.sharedInstance().currentWallet?.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet?.memberTypes[Resource.sharedInstance().currentUserId!] == .owner || tasks!.creatorID == Resource.sharedInstance().currentUserId || tasks!.doneByID == Resource.sharedInstance().currentUserId {
            if editingStyle == .delete {
                deleteIndex = indexPath
                let deletingtask = tasks!
                ConfirmDeletion(task: deletingtask)
            }
        }
    }
    
    @IBAction func AddNewTask(_ sender: Any) {
        performSegue(withIdentifier: "addTask", sender: nil)
    }
    
    func ConfirmDeletion(task : Task) {
        let alert = UIAlertController(title: "Delete Task", message: "Are you sure you want to permanently delete this Task", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: DeleteTask)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: Cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func DeleteTask(alertAction : UIAlertAction!) {
        if let indexPath = deleteIndex {
            tableview.beginUpdates()
            taskskey.remove(at: indexPath.row)
            tableview.deleteRows(at: [indexPath], with: .left)
            deleteIndex = nil
            tableview.endUpdates()
        }
    }
    
    func Cancel(alertAction : UIAlertAction!) {
        deleteIndex = nil
    }
    
    func taskAdded(_ task: Task) {
        if Resource.sharedInstance().currentWalletID == task.walletID {
            taskskey.append(task.id)
            print("Task Aya")
            tableview.reloadData()
        }
    }
    
    func taskDeleted(_ task: Task) {
        if task.walletID == Resource.sharedInstance().currentWalletID {
            for i in 0..<taskskey.count {
                if taskskey[i] == task.id {
                    taskskey.remove(at: i)
                    tableview.reloadData()
              }
            }
        }
    }
    
    func taskUpdated(_ task: Task) {
        if task.walletID == Resource.sharedInstance().currentWalletID {
//            for i in 0..<taskskey.count {
//                if taskskey[i] == task.id {
//                    taskskey[i] = task
                    tableview.reloadData()
//                }
//            }
        }
        
    }
    
    // Wallet member delegates
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        
    }
    
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        print("Member AA gaya")
    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
